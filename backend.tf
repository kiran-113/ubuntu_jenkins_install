# terraform {
#   backend "s3" {
#     bucket = "cloudnloud-app"
#     region = "us-east-1"
#     key    = "my-key/terraform.tfstate"
#   }
# }
terraform {
  backend "s3" {
    bucket = "tf-backend-1113"
    key    = "tf-backend"
    region = "us-east-1"
  }
}
