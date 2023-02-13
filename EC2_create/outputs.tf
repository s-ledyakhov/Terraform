output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "latest_windows_ami_id" {
  value = data.aws_ami.latest_windows.id
}

output "ubuntu_eip" {
  value = aws_eip.eip_ip_ubuntu.public_ip
}

output "ubuntu_id" {
  value = aws_instance.ubuntu.id
}

output "windows_eip" {
  value = aws_eip.eip_ip_windows.public_ip
}

output "windows_id" {
  value = aws_instance.windows.id
}

output "securiry_group_id" {
  value = aws_security_group.remote.id
}
