resource "aws_key_pair" "docker-key-pair" {
  key_name   = "docker-key-pair"
  public_key = file("c:/repos/key-pair.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_access"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows access from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-access-sg"
  }
}

module "docker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  key_name = aws_key_pair.docker-key-pair.key_name
  name = "docker"

  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-043783df234d1a42d"] 
  subnet_id = "subnet-0c5143ffdb39af59d" 
  ami = data.aws_ami.ami_info.id
  root_block_device = {
    volume_size = 50        
    volume_type = "gp3"      
  }

  tags = {
    Name = "docker"
  }
}