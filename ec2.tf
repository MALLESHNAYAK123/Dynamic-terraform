resource "aws_instance" "instance-1" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "t3.large"
  key_name = "nayak"
  subnet_id              = aws_subnet.public-subnets[0].id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  tags = {
    Name = "instance-1-${var.project_name}"
  }
}