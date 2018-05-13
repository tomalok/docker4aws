# Docker for AWS CloudFormation Template Tweaker

A program that tweaks [Docker for AWS](https://docs.docker.com/docker-for-aws/) CloudFormation templates to include missing/useful functionality.  This has been implemented as a script, rather than a set of patches, to work across the different editions/channels/versions of the [Docker for AWS](https://docks.docker.com/docker-for-aws/).

The modifications have been verified with the community edition, stable channel versions between 17.09.0-ce-aws1 and 18.03.1-ce-aws-1 with the "build-a-VPC" option.  Although currently unconfirmed, it is very likely that the enterprise edition, edge and beta channels, "don't-build-a-VPC" option, and other versions will also work.

----

## Features

Enhances Docker for AWS templates with the following features...

* ECR Auto-Authentication - Jake Buchholz

  * Adds AWS Elastic Container Registry (ECR) policies for Docker Swarm access.
    * separate policies for Manager and Worker nodes
    * selectable policy types, `pull-only` (default), `push-pull`, and `unspecified` (left up to other IAM policies)
    * applicable to all owned registries, or for specific lists of ECR ARNs

  * Refreshes and caches ECR credentials for the Docker Swarm.
    * addresses the issue discussed at https://github.com/docker/for-aws/issues/5 -- without a refresh, the credentials for any Docker service from an ECR would expire after 12 hours, preventing any non-assisted orchestration of that service
    * installs a `refresh-ecr-auth` script on Manager node [Moby](https://github.com/moby/moby) instances, which runs once when a Manager node is instantiated, and then every 8 hours via cron
    * configurable to allow credential caching for ECR in multiple regions and multiple AWS Accounts (defaults to current region, current account)

----

## Disclaimer

This patch is hereby released into the public domain in the hope that it will be useful, but without any warranty of any kind, expressed or implied.  In no event will the author of this patch be held liable for any damages or consequences of its use or misuse.
