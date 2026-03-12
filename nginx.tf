resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = "agvkeynew"
  vpc_security_group_ids = ["sg-07485c290aa7dbe75"]
  iam_instance_profile   = "agvrol"
  user_data              = file("${path.module}/userdata.sh")

  tags = {
    Name = var.project_name
  }
}

output "web_url" {
  description = "URL del dashboard"
  value       = "http://${aws_instance.web.public_ip}"
}