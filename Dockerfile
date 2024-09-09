FROM ruby:3.3.5@sha256:9ee601015fbb7c610ae02137d5698ab712f821069eaf7c0548e58a5b609970aa

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
