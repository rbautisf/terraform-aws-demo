## Bastion host SG and EC2 Instance
resource "aws_key_pair" "default" {
  key_name   = "KeyPair_${var.env}"
  public_key = var.public_ec2_key
  tags       = var.resource_tags
}

resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.amazon_linux_2_x86_64.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  provider                    = aws
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  key_name                    = aws_key_pair.default.key_name
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable postgresql14 -y
              yum clean metadata
              sudo yum install postgresql -y
              sudo yum install redis -y
              EOF
  tags                        = var.resource_tags
}