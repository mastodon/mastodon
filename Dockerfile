FROM ruby:2.2.4

ENV RAILS_ENV=production

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /mastodon

WORKDIR /mastodon

ADD Gemfile /mastodon/Gemfile
ADD Gemfile.lock /mastodon/Gemfile.lock

RUN bundle install --deployment --without test --without development

ADD . /mastodon

VOLUME ['/mastodon/public/system']
