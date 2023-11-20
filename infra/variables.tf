variable "service_name"{
    type = string
}

variable "port"{
    type = number
    default = 8080
    
}

variable "image_identifier"{
    type = string
    default = "244530008913.dkr.ecr.eu-west-1.amazonaws.com/2039-ecr-repo:latest"
}

variable "image_repository_type"{
    type = string
    default = "ECR"
}

variable "iam_role_name"{
    type = string
    default = "kjell-role-thingy"
}

variable "policy_name"{
    type = string
    default = "kjell-apr-policy-thingy"
}

variable "policy_description"{
    type = string
    default = "Policy for apprunner instance I think"
}