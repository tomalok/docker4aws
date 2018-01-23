# Docker for AWS CloudFormation Template Tweaks

## 17.12.0-ce-aws1-tomalok2

Patched [Docker for AWS](https://docs.docker.com/docker-for-aws/) CloudFormation templates containing tweaks that I happen to find useful.

***Work in Progress***

- [x] base off of latest Docker for AWS CloudFormation template
- [ ] include "tomalok2" in versioning
- [ ] incorporate ECR AutoAuth scripts/setup directly in template
- [ ] make ECR Auto-Authentication (and other patches) optional
- [ ] incorporate Auto Route53 record updates (https://github.com/30mhz/autoscaling-route53-lambda)

----

This patch version includes the following...

* ECR Auto-Authentication Patch - Jake Buchholz \<tomalok at gmail dot com\>

  * Reference issue: https://github.com/docker/for-aws/issues/5
  * Adds a read-only "ecr-policy" and attaches it to the Proxy (manager) and Worker roles.
  * Installs a script that basically does `$(aws ecr get-login --no-include-email)` for the root and docker users.
  * Sets up a cron job (on the moby instance) to run the script once every 8 hours.  Credentials are available in the `shell-aws` container because it mounts moby's `/home/docker`.
  * Runs the script once.
  * DISCLAIMER - This patch is hereby released into the public domain in the hope that it will be useful, but without any warranty of any kind, expressed or implied.  In no event will the author of this patch be held liable for any damages or consequences of its use or misuse.
