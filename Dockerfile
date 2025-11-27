# frozen_string_literal: true

FROM ruby:3.3.9-alpine

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    yaml-dev \
    gcompat

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
