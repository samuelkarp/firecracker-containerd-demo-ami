#!/bin/bash

########################
# include the magic
########################
. .magic/demo-magic.sh

# hide the evidence
clear

p "# Let's look at what images are here"
pe "fctr i ls"

p "# Let's try pulling an image from ECR"
pe "ecr-pull ecr.aws/arn:aws:ecr:us-west-2:011483493243:repository/httpbin:latest"

p "# Done!"
