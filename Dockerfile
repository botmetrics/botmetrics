FROM convox/rails

MAINTAINER Botmetrics <hello@getbotmetrics.com>

RUN apt-get update -qq && apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for a JS runtime
RUN apt-get install -y nodejs

#phusion passenger
RUN apt-get install -y wget curl 

# for psql
RUN apt-get install -y postgresql-client-9.5

ENV APP_HOME /botmetrics

RUN mkdir $APP_HOME

WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/

ADD Gemfile.lock $APP_HOME/

RUN bundle install --binstubs

ADD . $APP_HOME
