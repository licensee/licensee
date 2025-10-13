FROM ruby:3.4.7@sha256:8b60ef1d4853e1ecb76884e5f978a7c2c0e8de21daee36dd2038dff4d7447a7d

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
