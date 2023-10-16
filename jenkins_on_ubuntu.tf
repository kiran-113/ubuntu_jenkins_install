# Genaraetes Random number
resource "random_string" "random_number" {
  length  = 6 # Specify the desired length of the hexadecimal string
  special = false
}
# key_par
resource "tls_private_key" "oskey" {
  algorithm = "RSA"
}
# creates pem file locally 
# resource "local_file" "myterrakey" {
#   content  = tls_private_key.oskey.private_key_pem
#   filename = "${aws_key_pair.this.key_name}.pem"
# }

resource "aws_key_pair" "this" {
  key_name   = "my-ec2key-${random_string.random_number.result}"
  public_key = tls_private_key.oskey.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true


  #user_data                   = file("jenkins-server-script.sh")
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.oskey.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "jenkins_ubuntu.sh"
    destination = "/tmp/jenkins_ubuntu.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/jenkins_ubuntu.sh",
      "sudo /tmp/jenkins_ubuntu.sh",
      "sleep 10"
    ]
  }

  tags = {
    Name = "${var.env_prefix}-server"
  }

}
