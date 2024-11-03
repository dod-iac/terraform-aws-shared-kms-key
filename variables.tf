variable "allow_image_builder" {
  type        = bool
  description = "Allow EC2 Image Builder to send messages to SNS topics encrypted with the KMS key.  The allow_sns variable must be set, too."
  default     = false
}

variable "allow_cloudwatch" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt Cloudwatch logs."
  default     = false
}

variable "allow_ebs" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt EBS volumes."
  default     = false
}

variable "allow_eventbridge" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt EventBridge events."
  default     = false
}

variable "allow_lambda" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt Lambda environment variables."
  default     = false
}

variable "allow_s3" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt S3 buckets."
  default     = false
}
variable "allow_snow_family" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt the unlock code for your Snow Family job."
  default     = false
}

variable "allow_sns" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt SNS topics."
  default     = false
}

variable "allow_sqs" {
  type        = bool
  description = "Allow the KMS key to be used to encrypt SQS queues."
  default     = false
}

variable "description" {
  type        = string
  description = ""
  default     = "A KMS key shared by multiple services to encrypt data at-rest."
}

variable "key_deletion_window_in_days" {
  type        = string
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  default     = 30
}

variable "name" {
  type        = string
  description = "The display name of the alias. The name must start with the word \"alias\" followed by a forward slash (alias/)."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the KMS key."
  default     = {}
}
