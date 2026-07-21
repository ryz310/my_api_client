# syntax=docker/dockerfile:1

ARG RUBY_VERSION=4.0
FROM ruby:${RUBY_VERSION}-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

RUN gem install bundler -v "~> 2.0"

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app

EXPOSE 3000

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "3000"]
