variable "aws_region" {
default = "ap-southeast-1"
}
variable  "aws_profile"{
default = "terraform"
}
variable "public_key" {
default = "terraform.pub"
}
variable  "instance_type"{
default = "t2.micro"
}
variable  "ami_id"{
default = ""
}
variable  "instance_count"{
default = "1"
}
variable  "private_key"{
default = "terraform"
}
variable  "ansible_user"{
default = "ubuntu"
}
