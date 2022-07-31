variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}
variable "username" {
  description = "The Azure VM login user name"
 
}
variable "password" {
   description = "The Azure VM login user password"
}