terraform {
backend "s3" {
bucket = "mahsuda.net"
key = "jenkins/eu-west-1/tools/tools/jenkins.tfstate"
region = "eu-west-1"
  }
}
