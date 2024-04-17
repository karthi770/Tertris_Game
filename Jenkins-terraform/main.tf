resource "aws_iam_role" "jenkins_role" {
  name = "Jenkins-terraform"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "Jenkins-terraform"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_security_group" "jenkins-sg" {
  name        = "Jenkins-security-group"
  description = "Open 22,80,443,8080,9000,3000"
  vpc_id = "vpc-047714d71a6ec55f4"
  //ingress rule to allow all the ports to open, we use for loop here

  ingress = [
    for port in [22,80,443,8080,9000,3000] : {
        description       = "TLS from VPC"
        from_port         = port
        to_port           = port
        protocol          = "tcp"
        cidr_blocks       = ["0.0.0.0/0"]
        ipv6_cidr_blocks  = []
        self = false
        prefix_list_ids = []
        security_groups= []
    }
  ]

  egress {
        from_port = 0 //opening all ports
        to_port  = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.large"
  key_name = "jenkins"
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  subnet_id = "subnet-0c492c119d2652991"
  user_data = templatefile("./install_jenkins.sh", {})
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "Jenkins-argo"
  }

  root_block_device {
    volume_size = 30
  }
}
