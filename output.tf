output "ec2_public_ip" {

  value = "http://${aws_instance.myapp-server.public_ip}:8080"

}

output "sonarqube" {

  value = "http://${aws_instance.myapp-server.public_ip}:9000"

}

