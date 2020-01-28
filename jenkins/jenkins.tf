resource "aws_instance" "jenkins" {
  depends_on                  = ["aws_key_pair.jenkins"]
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "true"
  security_groups             = ["allow_ssh_and_jenkins"]
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_profile.name}",


  provisioner "file" {
   connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.ssh_key_location)}"
    }

    source      = "config"
    destination = "/tmp/config"
  }



  provisioner "remote-exec" {
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.ssh_key_location)}"
    }
    

    inline = [
	"sudo yum install java-1.8.0-openjdk-devel curl -y",
        "curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo",
        "sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key",
        "sudo yum install jenkins -y",
        "sudo systemctl start jenkins",


	"# These commands below installs docker and configure",
        "sudo curl -fsSL https://get.docker.com/ | sh",
	"sudo systemctl enable docker", 
	"sudo systemctl start docker",
        "sudo usermod -aG docker  -s /bin/bash jenkins", 
	"sudo cp -r /etc/skel/.*	/var/lib/jenkins",
        "sudo usermod -aG docker jenkins", 
	"sudo chmod 777 /var/run/docker.sock",	


	# These commands below sets up jenkins user",
	"ssh-keygen -b 2048 -t rsa -f /tmp/id_rsa  -q -N ''",
	"sudo mkdir /var/lib/jenkins/.ssh",
	"sudo chmod 600 /var/lib/jenkins/.ssh",
	"sudo cp /tmp/id_rsa*	/var/lib/jenkins/.ssh",
	"sudo cat /var/lib/jenkins/.ssh/id_rsa.pub",
	"sudo chmod +x /var/lib/jenkins/.ssh", 

        "# Installs packer",
        "sudo yum install wget unzip -y",
        "wget -P /tmp https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip",
        "unzip /tmp/packer_1.5.1_linux_amd64.zip",
        "sudo rm  /sbin/packer &>/dev/null  ",
        "sudo mv packer /bin",
        "packer version",
        

	"# These commands below installs terraform",
	"wget -P /tmp https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip",
	"unzip /tmp/terraform_0.11.14_linux_amd64.zip",
	"sudo mv terraform /bin",
	"terraform version",

        "# These commands below used for disabling host key verification",
        "sudo rm -rf /var/lib/jenkins/.ssh/known_hosts",
        "sudo chown -R jenkins:jenkins /var/lib/jenkins/",
        "sudo cp /tmp/config /var/lib/jenkins/.ssh",
        "sudo chmod 600 /var/lib/jenkins/.ssh/config",
        "sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/config",


	"# The commands below install awscli",
	"sudo yum install epel-release -y",
	"sudo yum install python-pip -y",
	"sudo pip install awscli",


    ]
  }


  tags = {
    Name = "Jenkins Don't delete please"
  }
}
