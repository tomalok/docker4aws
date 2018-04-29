# CHANGELOG

## [tomalok2] - unreleased
### Fixed
* when the instance hasn't fully joined the swarm yet, `refresh-ecr-auth.sh` will update `--with-registry-auth` in the background and retry for up to 5m.

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
