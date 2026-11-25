variable "name" {
  type    = string
  default = "kubernetes-on-arm-with-oracle"
}

/*
Available flex shapes:
"VM.Optimized3.Flex"  # Intel Ice Lake
"VM.Standard3.Flex"   # Intel Ice Lake
"VM.Standard.A1.Flex" # Ampere Altra
"VM.Standard.E3.Flex" # AMD Rome
"VM.Standard.E4.Flex" # AMD Milan
*/

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

# Oracle's Always Free tier for Ampere A1 used to be 4 OCPUs + 24 GB RAM.
# Since June 15, 2026 it is 2 OCPUs + 12 GB RAM in total (1,500 OCPU hours
# and 9,000 GB hours per month). The defaults below (2 nodes x 1 OCPU x 6 GB)
# use exactly that allowance. Going above it will be billed.
variable "how_many_nodes" {
  type    = number
  default = 2
}

# Kubernetes minor version, used for the pkgs.k8s.io package repository.
variable "kubernetes_version" {
  type    = string
  default = "1.36"
}

variable "availability_domain" {
  type    = number
  default = 0
}

variable "ocpus_per_node" {
  type    = number
  default = 1
}

variable "memory_in_gbs_per_node" {
  type    = number
  default = 6
}

# Warn (without blocking) when the configuration goes beyond the free tier.
check "always_free_tier" {
  assert {
    condition = (
      var.shape == "VM.Standard.A1.Flex" &&
      var.how_many_nodes * var.ocpus_per_node <= 2 &&
      var.how_many_nodes * var.memory_in_gbs_per_node <= 12
    )
    error_message = "This configuration exceeds Oracle's Always Free tier (VM.Standard.A1.Flex, 2 OCPUs and 12 GB RAM in total). You will be billed for the difference."
  }
}
