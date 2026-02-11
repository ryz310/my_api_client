# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.1.6
FROM ruby:${RUBY_VERSION}-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

RUN gem install bundler -v "~> 2.0"

COPY . /app

RUN bundle install

CMD ["bash"]
