resource "aws_instance" "docker_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = "agvkeynew"
  vpc_security_group_ids = ["sg-07485c290aa7dbe75"]
  iam_instance_profile   = "agvrol"
  user_data              = file("${path.module}/docker-userdata.sh")

  tags = {
    Name = "agv-docker"
  }
}

output "docker_url" {
  description = "URL del servicio Flask"
  value       = "http://${aws_instance.docker_server.public_ip}:5000"
}
