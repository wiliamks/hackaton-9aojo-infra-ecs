variable "hackaton" {
    description = "Variável Hackaton"
    type = string
    default = "hackaton"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "container_count" {
    type = number
    default = 1
}

variable "vpc_cidr" {
  description = "CIDR block for main"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allocated_storage" {
    type = number
    default = 10
}

variable "storage_type" {
    type = string
    default = ""
}

variable "db_name" {
    type = string
    default = "videoTraining"
}

variable "engine" {
    type = string
    default = "mysql"
}

variable "engine_version" {
    type = string
    default = "5.7"
}

variable "instance_class" {
    type = string
    default = "db.t3.micro"
}

variable "username" {
    type = string
    default = "admin"
}

variable "password" {
    type = string
    default = "hackathon1234"
}

variable "port" {
    type = number
    default = 3306
}

variable "identifier" {
    type = string
    default = "video-training-db"
}

variable "parameter_group_name" {
    type = string
    default = "default.mysql5.7"
}

variable "skip_final_snapshot" {
    type = bool
    default = true
}

#variable "private_subnets" {
#    type = list(string)
#    default = ["subnet-05e5e44d1f1dca991", "subnet-081b1819287923d4b"]
#}

variable "publicly_accessible" {
    type = bool
    default = true
}

data "aws_db_subnet_group" "subnets"  {
    subnets = [element(aws_db_subnet_group.default.*.name, count.index)]
}
