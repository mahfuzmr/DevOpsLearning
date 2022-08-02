variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "project01"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "South Central US"
}
variable "username" {
  description = "The Azure VM login user name"
  default = "mahfuzmr"
 
}
variable "password" {
   description = "The Azure VM login user password"
   default = "P@ssword01"
}