# CHANGELOG

## [tomalok2] - unreleased
### Added
* New template paramters!
  * Configurable Manager/Worker ECR policies!
    * Selectable `pull-only`, `push-pull`, and `unspecified` ECR policy types.
    * Specify list of ECR resource ARNs to which the ECR policy applies.
  * Configurable ECR auth login targets!
    * Enables swarm to cache/refresh ECR credentials for multiple regions and/or multiple AWS accounts.
    * Empty value disablees ECR credential caching/refreshing.
    * Default value of `=` expands to current region, current account-id.
    * A list of regions (i.e. `us-west-2,eu-central-1,ap-northeast-1`) caches/refreshes ECR creds for your account-id in those regions.
    * To access other accounts' ECR (provided they've granted access), use a `=` followed by a `:`-separated list of AccountIds, optionally after a specified region.
    * For example, `=,us-east-2=123456789012:112233445566,us-west-2=:210987654321`, would cache/refresh ECR creds for your account-id in the current region and us-west-2, for two other account-ids in us-east-2, and one other account-id in us-west-2.
* `install-refresh-ecr-auth.sh`
   * echoes prorgress (viewable in EC2 instance system logs).
   * sanitizes/expands ECR auth login targets.
   * only installs `refresh-ecr-auth.sh` if ECR auth login target(s) are specified.
* `refresh-ecr-auth.sh`
   * log to STDERR (for EC2 instance system logs) and syslog (/var/log/syslog).
   * refreshes ECR credentials for all specified ECR auth login targets.
### Fixed
* `refresh-ecr-auth.sh`
   * if the node isn't part of the swarm yet, retry update of services' `--with-registry-auth` for up to 60s; during testing, a new node typically took 10-11s to join the swarm.
### Changed
* `refresh-ecr-auth.sh` - only docker user needs ECR credentials
* `tweak-template`
  * only need to update Manager nodes' UserData (Workers get all instructions from them)
  * don't need to append patch version to ManageLaunchConfig name
  * more refining/streamlining of loading modifications from src/ and applying to source template.
  * explicity remove the old 'ECRPolicy' resource, which seems to have made it into mainline somehow...

## [tomalok1] - 2018-04-22
### Added
* added versioning to LaunchConfigurations
### Changed
* `tweak-template` script downloads and tweaks templates
  * generalized programmatic solution, no more per-base-template diffs
  * maintain components separately in a src/ subdirectory
* improved `refresh-ecr-auth.sh`
  * updates all swarm services `--with-registry-auth` after refreshing ECR auth

## [unversioned] - 2017-11-22
### Added
* `install-refresh-ecr-auth.sh` script, hosted in S3 bucket
  * writes the `refresh-ecr-auth.sh` script
  * executes it once to set up initial ECR credentials
  * updates crontab to run the script once every 8 hours
### Changed
* stock 17.09.01-aws1 CloudFormation template
  * added ECR Policy to Resources
  * added `wget -q0- https://s3-bucket/install-refresh-ecr-auth.sh | sh -ex` to Manager and Worker UserData
