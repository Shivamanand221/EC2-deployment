variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name (for SSH)."
  type = string
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "strapi_port" {
  type = number
  default = 1337
}

# Redis

variable "redis_node_type" {
  type = string
  default = "cache.t3.micro"
}

# S3

variable "s3_bucket_name" {
  type = string
  default = ""
  description = "Optional: supply to set an explicit bucket name. If empty, terraform will create a generated name."
}

# Misc
variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
  description = "CIDR allowed to SSH (restrict this in production)."
}