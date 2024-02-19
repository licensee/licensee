FROM ruby:3.3.0@sha256:5dbf566f4fb0aadf3a61346258d5b8d7e07bdfefc473a9f3eb1c619e9e8de178

WORKDIR /usr/src/app
RUN git init

RUN apt-get update && apt-get install -y cmake 

COPY Gemfile licensee.gemspec ./
COPY lib/licensee/version.rb ./lib/licensee/version.rb
RUN bundle install

COPY bin ./bin
COPY lib ./lib
COPY vendor ./vendor

ENTRYPOINT ["bundle", "exec", "./bin/licensee"]
