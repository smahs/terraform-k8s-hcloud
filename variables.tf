variable "hcloud_token" {
  description = "Create a project in hcloud and a token"
}

variable "location" {
  description = "The location to create the instances in. nbg1, fsn1 or hel1"
  default     = "hel1"
}

variable "master_count" {
  description = "Number of master nodes"
  default     = 1 
}

variable "master_image" {
  description = "Machine image that will be used to spin up the instance"
  default     = "ubuntu-18.04"
}

variable "master_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx11"
}

variable "node_count" {
  description = "Number of worker nodes"
  default     = 1
}

variable "node_image" {
  description = "Machine image that will be used to spin up the instance"
  default     = "ubuntu-18.04"
}

variable "node_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx11"
}

variable "ssh_private_key" {
  description = "Private Key to access the machines"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  description = "Public Key to authorized the access for the machines"
  default     = "~/.ssh/id_rsa.pub"
}

variable "feature_gates" {
  description = "Add Feature Gates e.g. 'DynamicKubeletConfig=true'"
  default     = ""
}

variable "flannel_install" {
  description = "Install Flannel overlay network"
  default     = true
}
