# Docker for AWS CloudFormation Template Tweaker

## TODO

Non-exhaustive wishlist of tweaks to add in future versions...

* Adding/removing Proxy and Worker nodes optionally updates Route53 A records.
  * Sometimes we just want to easily get to any master node or any swarm node.
  * Likely based on or using https://github.com/30mhz/autoscaling-route53-lambda?

* Configurable ELB/ELBv2
  * Disable load balancer(s) entirely
    * DNS straight to the nodes, and make use of the Docker Swarm mesh instead
  * More flexibility
    * Classic LB / Application LB / Network LB
    * Internal / External / Internal & External

* Encrypted EBS volumes?
