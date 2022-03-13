variable "name" {
  description = "Name to use for resources"
  default     = "twitter-dedupe"
}

variable "environment_variables" {
  description = "Runtime environment variables"
  type        = map(string)
}

variable "deploy_version" {
  description = "Version to deploy"
  default     = "latest"
}

variable "schedule" {
  description = "How often to run - EventBridge schedule expression"
  default     = "rate(5 minutes)"
}

