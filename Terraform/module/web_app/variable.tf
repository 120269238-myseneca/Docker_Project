variable "default_tags" {
  default = {}
  type    = map(any)

}


# Name prefix
variable "prefix" {
  type = string
}




variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}


variable "key_name" {
  type = string
}


variable "subnet_id" {
  type    = list(string)
}



variable "sg_id" {
  type    = list(string)
}


variable "user_data" {
  type = string
}

variable "iam_instance_profile" {
  type        = string
}
