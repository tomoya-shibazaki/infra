
resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "my_bastion"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDb5FItDGUn1nKj2uhhNGau35adb1IkKjvxZdb9UTh2j5JsS8zFJojupnel9rpMit9QqgpBkRrqYj3GXDsYcY/RaaWZqaDZbhiDL7i1yfrKyH8+E3NEsOK2UGoR2NU43v1Vi8DC2LyibpQXiO0hMUOxwVsseuccDf2lrwZY13KbafuMeyjTbf2HwoSmJ704+8V5rgwaGduDs6RoCya7YRpXHW8asXPrgJQFgp8q5XX9WGydThlOHorGxyEllTI3zHbpKSxRw+R96YTsHaRaq1rcpC4bSsAdtvQZ/STdmTDzs4pIvxqZa1qKBSfqiVMPibmmW3tOXieh+p0xIH2YaV3U9CaR9SWcylG3VVfKUJb0v5uYUUmDkCvcRmkr0SemWXT/2M/yEpVWDjahYsEPGDdbsle3ajzlnTl3i3D7UEauPb2FU+i2UDZDK6ES7MXgVSZFxKP3hBhtTkWoOXi4YtS8skkz4lpwHbLMGRXfiFRvtGzpUrSUckDynRgOclpjK9eitxryiyxF+oE6hcxFLQz9niDL8CpdzTsGhjPalUYR/YO/pZXTOHQAxktGqVxbevlz6CoKqaRL4GWbiHBooXEr6CVMTXJuNbEOldI7AQ0Ah+ozDLKPVRuIQ0vAL8le2xCu9ZWnsWyqsgsN1/mkaEgOzD1qBq41LNpnlGVCJkBvTQ== tshibazaki8165@gmail.com"
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0218d08a1f9dac831"
  key_name                    = aws_key_pair.bastion_key.key_name
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

