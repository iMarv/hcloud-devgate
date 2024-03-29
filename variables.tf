variable "hcloud_token" {
  type        = string
  description = "The API-Token that shall be used to create your server"
}

variable "floating_ip_address" {
  type        = string
  description = "The Ipv4 address of the floating IP that is attached to the server for easier access"
}

variable "projects_volume_id" {
  type        = string
  description = "ID of an existing volume which is going to store your projects"
}

variable "ssh_keys" {
  type        = list(string)
  description = "Array of ssh keys that can log into the root user of the devgate"
}

variable "user_name" {
  type        = string
  description = "Name of the user that will be created"
}

variable "git_user" {
  type        = string
  description = "Name of the git user"
}

variable "git_mail" {
  type        = string
  description = "Mail adress of the git user"
}

variable "ssh_key_path" {
  type        = string
  description = "Path to private ssh key to use for authentication when setting up the server"
}

variable "keypair_name" {
  type        = string
  description = "Name of the keypair files that are copied to the devgate"
}

variable "devenv" {
  type        = string
  description = "Environment to prepare. Currently available: node, rust, clojure"
}

variable "git_editor" {
  type        = string
  description = "Default editor to be used by git"
  default     = "vim"
}

variable "location" {
  type        = string
  description = "Location of the server"
  default     = "nbg1"
}

variable "server_type" {
  type        = string
  description = "Server Type of the server"
  default     = "cx51"
}
