
variable "image_id" {
  #default = "fd8ps4vdhf5hhuj8obp2" # ubuntu
  default = "fd8jovjm8s9nem04bfv3" # debian 10
}

variable "count_vm" {
  default = 2
}

variable "hostnames" {
  default = {
    "0" = "elvm1"
    "1" = "elvm2"
  }
}
