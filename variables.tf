variable "resource_group_location" {
  type        = string
  default     = "centralus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "eric_tf_onms_minion_emulator_CentralUS_rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "minion"
}

variable "key_name" {
    type = string
}

variable "public_key_path" {
    type = string
}

variable "instances" {
  type = any
  default = {
    "minionVM" = {
      "nic_name" = "minion_nic"
    }
    "emulatorVM" = {
      "nic_name" = "emulator_nic"
    }
  }
}
