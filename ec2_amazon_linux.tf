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

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 20
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.oskey.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "jenkins-server-script.sh"
    destination = "/tmp/jenkins-server-script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/jenkins-server-script.sh",
      "sudo /tmp/jenkins-server-script.sh",
      "sleep 10"
    ]
  }

  tags = {
    Name = "${var.env_prefix}-server"
  }

}
