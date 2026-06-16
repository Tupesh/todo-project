variable "my_ip" {
  description = "Public IP or CIDR range allowed to access AWS resources"
  type        = string
}

variable "key_pair_name" {
  description = "AWS EC2 key pair name used to SSH into instances"
  type        = string
}

