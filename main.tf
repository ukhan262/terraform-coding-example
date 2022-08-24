locals {

  regions = toset(["WESTUS2", "EASTUS2"])
  ss-refactored = {
    "npe" = {
      "Ansible" = {
        instance    = "1",
        owner_email = "umarkhan252@gmail.com"
      },
      "Iris" = {
        instance    = "2",
        owner_email = "umarkhan252@gmail.com"
      },
      "Privacera" = {
        instance    = "3",
        owner_email = "umarkhan252@gmail.com"
      }
    }
    "prd" = {
      "Ansible" = {
        instance    = "1",
        owner_email = "umarkhan252@gmail.com"
      },
      "Github" = {
        instance    = "1",
        owner_email = "umarkhan252@gmail.com"
      },
      "TFE" = {
        instance    = "2",
        owner_email = "umarkhan252@gmail.com"
      }
    }
  }

  ss-flatten = flatten([
    for region in local.regions : [
      for env, env_object in local.ss-refactored : [
        for ss, sss in env_object : [
          {
            env            = env
            shared_service = ss
            instance       = sss.instance
            owner_email    = sss.owner_email
            region         = region
          }
        ]
    ]]
  ])

}

variable "tags" {
  default = {
    "Application" = "poc"
    "Environment" = "poc"
  }
}


resource "azurerm_resource_group" "main" {
  for_each = { for ss in local.ss-flatten : "${ss.env}-${ss.region}-${ss.shared_service}" => ss }
  name     = "${each.value.env}-${each.value.shared_service}-${each.value.instance}"
  location = each.value.region
  tags     = var.tags
}

output "ss-flatted" {
  value = local.ss-flatten
}

# map of string = object
# list of object = tuple
# tuple = [
#     { "" = ""}, 
#     { "" = ""}
# ]
