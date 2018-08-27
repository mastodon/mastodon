# AWS Cloudformation Stack - End to End deployment
* 1x EC2 Server (Dockerised Mastodon Instance)
* 1x RDS PostgreSQL (for Database)
* 1 x ElasticCache Redis (for shared cache)
* 1 x S3 Bucket for storage (with AWS IAM account)

## Installation Guide
1) Setup a new Route53 zone and forward the domain nameservers correctly.
2) Register with mailgun.com and setup required DNS records for approval.
3) Create the AWS CFN Stack with the required details.
4) Register an account on your instance (log in and promote as admin using cli)

## TODO
* Setup scheduled tasks (documentation related to recommend tasks is slim)
* Automate creation of admin account (task is currently interactive only)
