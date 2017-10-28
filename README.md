# Botmetrics

Botmetrics is the easy, secure, open-source way for you to measure and
engage with your chat-bot users.

Botmetrics works natively with Messenger, Slack and Kik bots with
support for other messaging platforms coming soon.

[![CircleCI](https://circleci.com/gh/botmetrics/botmetrics/tree/master.svg?style=svg)](https://circleci.com/gh/botmetrics/botmetrics/tree/master)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/botmetrics/botmetrics)

### [Deploy to AWS](#deploying-botmetrics-to-aws-with-convox)

## Analytics

With Botmetrics, you can get analytics for your bot with very little
code, and native SDKs available in

* [Node.JS](https://github.com/botmetrics/botmetrics.js)
* [Ruby](https://github.com/botmetrics/botmetrics-rb)
* [Go](https://github.com/botmetrics/go-botmetrics)

![Metrics](https://github.com/botmetrics/botmetrics/raw/master/app/assets/images/homepage/metrics.png)

## Insights

You can gain more insight into the users using your bot and perform
sophisticated queries to find out who they are.

![Analyze](https://github.com/botmetrics/botmetrics/raw/master/app/assets/images/homepage/analyze.png)

## Notifications

You can gain more insight into the users using your bot and send then
re-engagement notifications based on pre-selected criteria.

![Notifications](https://github.com/botmetrics/botmetrics/raw/master/app/assets/images/homepage/notifications.png)

## Installation

* [Heroku](https://botmetrics.readme.io/docs/running-botmetrics-on-heroku#section-deploying-botmetrics-to-heroku)
* [AWS](https://botmetrics.readme.io/docs/production-on-amazon-web-services#section-deploying-botmetrics-to-aws-with-convox)
* [Linux](https://botmetrics.readme.io/docs/running-botmetrics-on-linux#section-installing-botmetrics-for-production-on-linux)

## Updating your Installation

* [Heroku](https://botmetrics.readme.io/docs/running-botmetrics-on-linux#section-installing-botmetrics-for-production-on-linux)
* [AWS](https://botmetrics.readme.io/docs/production-on-amazon-web-services#section-updating-your-aws-installation)

## Development

1. `cp .env-example .env`
2. `cp config/database.yml.sample config/database.yml`
3. Start Redis & Postgres (there's a `./script/redis` and
   `./script/dbstart` command that lets you do this easily)
4. Run `./script/dbreset` to reset the database (creates a new one,
   loads schema and runs `rake db:seed`)
5. Run `./script/server` to start the server
6. Visit [localhost:3000](http://localhost:3000)

## Contributing

* Join the [Slack](https://slack.getbotmetrics.com) channel to ask questions
* Open a [GitHub Issue](https://github.com/botmetrics/botmetrics/issues/new) for bugs/feature requests
* Create a [GitHub Pull Request](https://help.github.com/articles/using-pull-requests/) to submit patches

## Wiki

Extra information can be found in the [wiki](https://github.com/botmetrics/botmetrics/wiki).

## Roadmap

The Botmetrics Roadmap can be seen
[here](https://github.com/botmetrics/botmetrics/projects/1).

## CircleCI

[![CircleCI](https://circleci.com/gh/botmetrics/botmetrics/tree/master.svg?style=svg)](https://circleci.com/gh/botmetrics/botmetrics/tree/master)

## Stay Connected

Follow [Botmetrics on Twitter](https://www.twitter.com/getbotmetrics/?utm_source=github&utm_campaign=repo&utm_keyword=botmetrics_repo) to get the latest updates.

Read the [Botmetrics Blog](http://blog.getbotmetrics.com/?utm_source=github&utm_campaign=repo&utm_keyword=botmetrics_repo) for more How tos, success stories and more.
