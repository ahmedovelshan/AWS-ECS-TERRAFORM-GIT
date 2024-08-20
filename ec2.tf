data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] 
}

resource "aws_network_interface" "web-ec2-network" {
  subnet_id   = aws_subnet.web-subnet[count.index].id
  count = length(var.web-subnet-cidr)
  security_groups = [aws_security_group.alb-to-web.id]
}


resource "aws_instance" "web-ec2-instances" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count = length(var.web-subnet-cidr)

  network_interface {
    network_interface_id = aws_network_interface.web-ec2-network[count.index].id
    device_index         = 0
  }
  user_data = <<-EOF
              #!/bin/bash
              # Update package list and install Apache
              apt-get update
              apt-get install -y apache2

              # Get the hostname and IP address
              HOSTNAME=$(hostname)
              IP_ADDRESS=$(hostname -I | awk '{print $1}')

              # Create an HTML file with hostname and IP address
              echo "<!DOCTYPE html>" > /var/www/html/index.html
              echo "<html lang=\"en\">" >> /var/www/html/index.html
              echo "<head><meta charset=\"UTF-8\"><title>Host Info</title></head>" >> /var/www/html/index.html
              echo "<body>" >> /var/www/html/index.html
              echo "<h1>Host Information</h1>" >> /var/www/html/index.html
              echo "<p><strong>Hostname:</strong> $HOSTNAME</p>" >> /var/www/html/index.html
              echo "<p><strong>IP Address:</strong> $IP_ADDRESS</p>" >> /var/www/html/index.html
              echo "</body></html>" >> /var/www/html/index.html

              # Ensure Apache is running
              systemctl start apache2
              systemctl enable apache2
              EOF
}



resource "aws_lb_target_group_attachment" "tec2-to-alb-tg" {
  target_group_arn = aws_lb_target_group.web-inctances.arn
  target_id        = aws_instance.web-ec2-instances[count.index].id
  port             = 80
  count = length(var.web-subnet-cidr)
}
