resource "null_resource" "jenkins_passwd" {
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = ["aws_route53_record.jenkins"]

  provisioner "remote-exec" {
    connection {
      host        = "jenkins.acirrustech.com"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.ssh_key_location)}"
    }

    inline = [
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
    ]
  }
}

