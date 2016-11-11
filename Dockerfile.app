FROM ruby:2.3.1

ENV RAILS_ENV=production

RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main contrib non-free' >> /etc/apt/sources.list
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libxml2-dev libxslt1-dev nodejs ffmpeg && rm -rf /var/lib/apt/lists/*
RUN npm install -g npm@3 && npm install -g yarn
RUN mkdir /mastodon

WORKDIR /mastodon

ADD Gemfile /mastodon/Gemfile
ADD Gemfile.lock /mastodon/Gemfile.lock
RUN bundle install --deployment --without test development

ADD package.json /mastodon/package.json
ADD yarn.lock /mastodon/yarn.lock
RUN yarn

ADD . /mastodon

VOLUME ["/mastodon/public/system", "/mastodon/public/assets"]
