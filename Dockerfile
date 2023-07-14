FROM ruby:3.1.3

RUN set -ex && \
    apt-get update

WORKDIR /app
COPY Gemfile ./
RUN bundle install
COPY . .
