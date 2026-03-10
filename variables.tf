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
  description = "AMI para la instancia EC2 (Ubuntu 22.04 us-east-1)"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "aws-dashboard"
}