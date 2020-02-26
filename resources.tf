resource "aws_key_pair" "terraform" {
  key_name = "terraform"
  public_key  = "${file(var.public_key)}"
}

/*resource "aws_vpc" "myvpc" {
  cidr_block =  "10.0.0.0./16"
  instance_tenancy  = "default"

tags {
  Name = "${var.aws_vpc}"
}
}*/

resource "aws_instance" "myinstance" {
  instance_type = var.instance_type
  ami = var.ami_id
  count = var.instance_count
  key_name  = "${aws_key_pair.terraform.key_name}"
  vpc_security_group_ids  = ["${aws_security_group.ssh.id}"]
tags  = {
  Name =  "Ansible_instance-${count.index +1 }"
}

connection {
 type = "ssh"
 #host = aws_instance.myinstance.*.public_ip
 host = coalesce(self.public_ip, self.private_ip)
 private_key = file(var.private_key)
 user =  "var.ansible_user"
}

provisioner "remote-exec" {
 inline = ["sudo apt-get -qq install python -y"]
}

provisioner "local-exec" {
command = <<EOT
      sleep 30;
	  >java.ini;
	  echo "[java]" | tee -a java.ini;
	  echo "${aws_instance.myinstance.*.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a java.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i java.ini ../playbooks/install_java.yaml
    EOT
}

provisioner "local-exec" {
command = <<EOT
      sleep 600;
    >myinstance.ini;
    echo "[myinstance]" | tee -a myinstance.ini;
    echo "${aws_instance.myinstance.*.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a jenkins-ci.ini;
    export ANSIBLE_HOST_KEY_CHECKING=False;
    ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i myinstance.ini ../playbooks/install_jenkins.yaml
    EOT
}

}
resource  "aws_security_group" "ssh" {
  name =  "default-ssh"

  ingress  {
   from_port = 22
   to_port  = 22
   protocol =  "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
   from_port = 80
   to_port = 80
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port  = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
  Name = "ssh-example"
  }
}
