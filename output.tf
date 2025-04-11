output "az" {
  value = data.aws_availability_zones.az1.names
}

output "lenth-az" {
  value = length(data.aws_availability_zones.az1.names)
}