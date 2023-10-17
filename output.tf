output "Jenkins_web" {

  value = "http://${aws_instance.myapp-server.public_ip}:8090"

}

output "sonarqube" {

  value = "http://${aws_instance.myapp-server.public_ip}:9000"

}
output "ec2_public_ip" {

  value = aws_instance.myapp-server.public_ip

}


