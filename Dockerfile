FROM ruby:3.4.7@sha256:cff944ca9f1398116ca31573b65a9f4e2e71336701f9229cb24a2e023e477a00

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
