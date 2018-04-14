# Docker

To setup webpacker with a dockerized Rails application is trivial.

First, add a new service for webpacker in docker-compose.yml:

```Dockerfile
version: '3'
services:
  webpacker:
    build: .
    env_file:
      - '.env.docker'
    command: ./bin/webpack-dev-server
    volumes:
      - .:/webpacker-example-app
    ports:
      - '3035:3035'
```

add nodejs and yarn as dependencies in Dockerfile,

```dockerfile
FROM ruby:2.4.1
RUN apt-get update -qq

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn

# Rest of the commands....
```

and create an env file to load environment variables from:

```env
NODE_ENV=development
RAILS_ENV=development
WEBPACKER_DEV_SERVER_HOST=0.0.0.0
```

Lastly, rebuild your container:

```bash
docker-compose up --build
```
