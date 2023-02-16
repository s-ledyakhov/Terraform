output "bastion_eip" {
  value = aws_eip.bastion_eip.public_ip
}

output "latest_amazon_linux_id" {
  value = data.aws_ami.ami_latest_ami.id
}

output "latest_amazon_linux_date" {
  value = data.aws_ami.ami_latest_ami.creation_date
}