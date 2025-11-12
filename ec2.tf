resource "aws_key_pair" "deployer" {
  key_name   = "my-deployer-key"
  public_key = file("${path.module}/../../../.ssh/id_rsa.pub")
}

resource "aws_instance" "this" {
  ami                    = "ami-069e612f612be3a2b" # This is RHEL AMI ID
  vpc_security_group_ids = [aws_security_group.allow_all_demo.id]
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name

  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  user_data = file("diskresize.sh")
  tags = {
    Name    = "demo-eks-instance"
  }
}

resource "aws_security_group" "allow_all_demo" {
  name        = "allow_all_demo"
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
output "ec2_ip" {
  value       = aws_instance.this.public_ip
}