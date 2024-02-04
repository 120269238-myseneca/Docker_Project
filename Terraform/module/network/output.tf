# /Terraform/module/network/output.tf

output "vpc_id" {
  value = aws_vpc.main_cidr.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.*.id
}