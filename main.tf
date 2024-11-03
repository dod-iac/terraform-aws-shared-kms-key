/**
 * ## Usage
 *
 * Creates a KMS Key shared by multiple services to encrypt data at-rest.
 *
 * ```hcl
 * module "shared_kms_key" {
 *   source = "dod-iac/shared-kms-key/aws"
 *
 *   name = format("alias/app-%s-shared-%s", var.application, var.environment)
 *   description = format("A shared key used to encrypt data at rest for %s:%s.", var.application, var.environment)
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 *   allow_lambda = true
 *   allow_s3 = true
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

# https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_iam_role" "imagebuilder" {
  count = var.allow_sns && var.allow_image_builder ? 1 : 0
  name  = "AWSServiceRoleForImageBuilder"
}

data "aws_iam_policy_document" "main" {
  policy_id = "key-policy-main"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.allow_ebs ? [1] : []
    content {
      sid = "Allow EBS to use the key"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:CallerAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = [format("ec2.%s.amazonaws.com", data.aws_region.current.name)]
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_lambda ? [1] : []
    content {
      sid = "Allow Lambda execution role to use the key"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:CallerAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = [format("lambda.%s.amazonaws.com", data.aws_region.current.name)]
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_s3 ? [1] : []
    content {
      sid = "Allow S3 to use the key"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:CallerAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = [format("s3.%s.amazonaws.com", data.aws_region.current.name)]
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_snow_family ? [1] : []
    content {
      sid = "Allow Snow Family to use the key"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:List*",
        "kms:CreateGrant"
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:CallerAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = [format("importexport.%s.amazonaws.com", data.aws_region.current.name)]
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_sqs ? [1] : []
    content {
      sid = "Allow SQS to use the key"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:CallerAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = [format("sqs.%s.amazonaws.com", data.aws_region.current.name)]
      }
    }
  }

  dynamic "statement" {
    for_each = length(sort(flatten([
      (var.allow_cloudwatch ? ["cloudwatch.amazonaws.com"] : []),
      (var.allow_eventbridge ? ["events.amazonaws.com"] : []),
      (var.allow_s3 ? ["s3.amazonaws.com"] : []),
      (var.allow_sns ? ["sns.amazonaws.com"] : []),
    ]))) > 0 ? [1] : []
    content {
      sid = "Allow services to use the key"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ]
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = sort(flatten([
          (var.allow_cloudwatch ? ["cloudwatch.amazonaws.com"] : []),
          (var.allow_eventbridge ? ["events.amazonaws.com"] : []),
          (var.allow_s3 ? ["s3.amazonaws.com"] : []),
          (var.allow_sns ? ["sns.amazonaws.com"] : []),
        ]))
      }
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = (var.allow_sns && var.allow_image_builder) ? [1] : []
    content {
      sid = "Allow EC2 Image Builder"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ]
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = [data.aws_iam_role.imagebuilder[0].arn]
      }
      resources = ["*"]
    }
  }

}

resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.main.json
  tags                    = var.tags
}

resource "aws_kms_alias" "main" {
  name          = var.name
  target_key_id = aws_kms_key.main.key_id
}