FROM ruby:3.3.0@sha256:94cb8c8b8e09dad143148ce698828fa904793fde26b5c7f60b3ae17cecf7c1ad

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
