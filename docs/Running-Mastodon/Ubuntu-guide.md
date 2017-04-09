# A guide to installing Mastodon on Ubuntu 16.04 LTS (amd64 and arm64).

A really good guide is at 

https://github.com/ummjackson/mastodon-guide/blob/master/up-and-running.md

Go read it, I won't repeat myself.

## Running under Docker

### Installing Docker and docker-compose

Issue #869, docker-compose build fails. The package that you get from 
Docker when you do `apt-get install docker-compose` is too old. 

Install on amd64 machines from the PPA: (instructions)

Docker for arm64 needs to be installed from source: (instructions) 
