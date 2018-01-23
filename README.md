# Docker for AWS CloudFormation Template Tweaks

Patched [Docker for AWS](https://docs.docker.com/docker-for-aws/) CloudFormation templates containing tweaks that I happen to find useful.

Subdirectory names indicate the original Docker for AWS version and the corresponding patch version.

----

## Features

The current patch version includes the following...

* ECR Auto-Authentication Patch - Jake Buchholz \<tomalok at gmail dot com\>

  * Reference issue: https://github.com/docker/for-aws/issues/5
  * Adds a read-only "ecr-policy" and attaches it to the Proxy (manager) and Worker roles.
  * Installs a script that basically does `$(aws ecr get-login --no-include-email)` for the root and docker users.
  * Sets up a cron job (on the moby instance) to run the script once every 8 hours.  Credentials are available in the `shell-aws` container because it mounts moby's `/home/docker`.
  * Runs the script once.
  * DISCLAIMER - This patch is hereby released into the public domain in the hope that it will be useful, but without any warranty of any kind, expressed or implied.  In no event will the author of this patch be held liable for any damages or consequences of its use or misuse.

----

## TODO

Non-exhaustive wishlist of tweaks to add in future versions...

* Embed scripts/files into the CloudFormation template, no longer need to pull the install script from my S3 bucket.

* Make the ECR Auto-Auth patch (and other patches) optional when deploying/updating the CloudFormation template.

* Adding/removing Proxy and Worker nodes optionally updates Route53 A records.
  * Sometimes we just want to easily get to any master node or any swarm node.
  * Likely based on or using https://github.com/30mhz/autoscaling-route53-lambda?

* Configurable ELB/ELBv2
  * Disable load balancer(s) entirely
    * DNS straight to the nodes, and make use of the Docker Swarm mesh instead
  * More flexibility
    * Internal / External / Internal and External
    * Classing / Application LB / Network LB

* Encrypted EBS volumes?
