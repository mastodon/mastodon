# AWS Cloudformation Stack - End to End deployment
* 1x EC2 Server (Dockerised Mastodon Instance)
* 1x RDS PostgreSQL (for Database)
* 1 x ElasticCache Redis (for shared cache)
* 1 x S3 Bucket for storage (with IAM user account linked)

## Installation Guide
1) Setup a new Route53 zone and forward the domain nameservers correctly.
2) Register with mailgun.com and setup required DNS records for approval.
3) Create the AWS CFN Stack with the required details.
4) Register an account on your instance (log in and promote as admin using cli)

## Troubleshooting
User-data/meta-data debug information is stored in /var/tmp/bootstrap.txt - `/var/tmp$ tail -f /var/tmp/bootstrap.txt`

## TODO
* Setup scheduled tasks (documentation related to recommend tasks is slim)
* Automate creation of admin account (task is currently interactive only)
* Build AWS Elasticsearch in the stack?
* KMS for at-rest encryption
* EIP for dedicated Public IP.

## Cost
* Monthly cost is about $50-100!
* I'm running my https://aus.social instance on t2.small instances and we're almost at 100 active users.
* While much more expensive than digital ocean but much more stable with lower techdebt due to the managed services (RDS/ElasticCache).

## Automation steps
* Creates ec2 instance (t2.small can support hundreds of users)
* Installs Ubuntu 18.04
* Installs supporting packages
* Installs all updates
* TODO: Install held AWS packages
* --
* Setups DNS record on Route53
* Creates mastodon user
* Installs docker
* Installs docker-compose
* Setups swap
* --
* clones mastodon 
* tweaks docker-compose.yml
* creates .env.production
* builds docker images
* prepares the DB
* precompiles assets
* boots docker
* --
* Installs nginx
* configures nginx 
* Installs certbot for LetsEncypt TLS
* --
* Reboots box
