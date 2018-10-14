# laps.run terraform

terraform manifests for [laps.run](https://laps.run)

[![Build Status](https://travis-ci.com/lapsrun/terraform.svg?branch=master)](https://travis-ci.com/lapsrun/terraform)

### osx setup

```
brew update
brew install awscli
aws configure --profile personal

# ensure you don't have any existing aws env vars set
env | grep -i aws

git clone git@github.com:lapsrun/terraform.git
cd terraform

AWS_PROFILE=personal terraform init

AWS_PROFILE=personal terraform plan -out=plan
AWS_PROFILE=personal terraform apply plan
```
