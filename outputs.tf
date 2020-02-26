output "url-jenkins" {
  value = "http://${aws_instance.myinstance.0.public_ip}:8080"
}
