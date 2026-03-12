variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI Amazon Linux 2023 us-east-1"
  type        = string
  default     = "ami-0c421724a94bba6d6"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "aws-dashboard"
}