FROM ruby:2.5.3-alpine

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  chromium-chromedriver \
  chromium \
  postgresql \
  postgresql-dev \
  nodejs \
  nodejs-npm \
  tzdata


RUN addgroup -g 1000 -S theodor && \
    adduser -u 1000 -S theodor -G theodor
USER theodor

RUN mkdir /home/theodor/app
WORKDIR /home/theodor/app
COPY --chown=theodor:theodor Gemfile* /home/theodor/app/
RUN bundle install --jobs 4 --retry 3
COPY --chown=theodor:theodor . /home/theodor/app/
