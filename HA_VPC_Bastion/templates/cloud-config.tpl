#cloud-config
runcmd:
  - aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${bastion_eip} --allow-reassociation --region $(curl http://169.254.169.254/latest/meta-data/placement/region)