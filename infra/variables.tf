variable "service_name"{
    type = string
    default = "apprunner-2039"
}

variable "image_identifier"{
    type = string
    default = "244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo"
}

variable "iam_role_name"{
    type = string
    default = "2039-role-thingy"
}

variable "policy_name"{
    type = string
    default = "2039-apr-policy-thingy"
}

variable "policy_description"{
    type = string
    default = "Policy for apprunner instance I think"
}

variable "candidate_number"{
    type = string
    default = "candidate_2039"
}