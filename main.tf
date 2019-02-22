terraform {
  required_version = "= 0.11.12"

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "lapsrun"
    workspaces {
      name = "main"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "running_venues_site_name" {
  default = "laps.run"
}

resource "aws_s3_bucket" "laps_run" {
  bucket        = "${var.running_venues_site_name}"
  acl           = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

data "aws_iam_policy_document" "laps_run" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.running_venues_site_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "laps_run" {
  bucket = "${aws_s3_bucket.laps_run.id}"
  policy = "${data.aws_iam_policy_document.laps_run.json}"
}

resource "aws_s3_bucket" "laps_run_www" {
  bucket        = "www.${var.running_venues_site_name}"
  acl           = "public-read"
  force_destroy = true

  website {
    redirect_all_requests_to = "${aws_s3_bucket.laps_run.id}"
  }
}

data "aws_iam_policy_document" "laps_run_www" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::www.${var.running_venues_site_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "laps_run_www" {
  bucket = "${aws_s3_bucket.laps_run_www.id}"
  policy = "${data.aws_iam_policy_document.laps_run_www.json}"
}

resource "aws_s3_bucket" "laps_run_preview" {
  bucket        = "${var.running_venues_site_name}-preview"
  acl           = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  lifecycle_rule {
    id      = "/"
    prefix  = ""
    enabled = true

    expiration {
      days = 7
    }
  }
}

data "aws_iam_policy_document" "laps_run_preview" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.running_venues_site_name}-preview/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "laps_run_preview" {
  bucket = "${aws_s3_bucket.laps_run_preview.id}"
  policy = "${data.aws_iam_policy_document.laps_run_preview.json}"
}

resource "aws_s3_bucket" "laps_run_ops" {
  bucket        = "ops.${var.running_venues_site_name}"
  force_destroy = true
  acl           = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

data "aws_iam_policy_document" "laps_run_ops" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::ops.${var.running_venues_site_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "laps_run_ops" {
  bucket = "${aws_s3_bucket.laps_run_ops.id}"
  policy = "${data.aws_iam_policy_document.laps_run_ops.json}"
}

resource "aws_s3_bucket" "laps_run_ops_data_private" {
  bucket        = "${var.running_venues_site_name}-ops-data-private"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_iam_access_key" "laps_run_ci" {
  user = "${aws_iam_user.laps_run_ci.name}"
}

resource "aws_iam_user" "laps_run_ci" {
  name = "laps_run"
  path = "/"
}

data "aws_iam_policy_document" "laps_run_ci" {
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.running_venues_site_name}/*"]
  }

  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.running_venues_site_name}-preview/*"]
  }

  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    resources = [
      "arn:aws:s3:::${var.running_venues_site_name}-ops-data-private/*",
    ]
  }
}

resource "aws_iam_user_policy" "laps_run_ci" {
  name   = "laps_run_ci"
  user   = "${aws_iam_user.laps_run_ci.name}"
  policy = "${data.aws_iam_policy_document.laps_run_ci.json}"
}

resource "aws_iam_access_key" "ops_laps_run_ci" {
  user = "${aws_iam_user.ops_laps_run_ci.name}"
}

resource "aws_iam_user" "ops_laps_run_ci" {
  name = "ops_laps_run"
  path = "/"
}

data "aws_iam_policy_document" "ops_laps_run_ci" {
  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    resources = [
      "arn:aws:s3:::ops.${var.running_venues_site_name}/*",
    ]
  }

  statement {
    actions = ["s3:*"]
    effect  = "Allow"

    resources = [
      "arn:aws:s3:::${var.running_venues_site_name}-ops-data-private",
      "arn:aws:s3:::${var.running_venues_site_name}-ops-data-private/*",
    ]
  }
}

resource "aws_iam_user_policy" "ops_laps_run_ci" {
  name   = "ops_laps_run_ci"
  user   = "${aws_iam_user.ops_laps_run_ci.name}"
  policy = "${data.aws_iam_policy_document.ops_laps_run_ci.json}"
}
