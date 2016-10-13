# Botmetrics

Botmetrics is the easy, secure, open-source way for you to measure and
engage with your chat-bot users.

Botmetrics works natively with Messenger, Slack and Kik bots with
support for other messaging platforms coming soon.

[![CircleCI](https://circleci.com/gh/botmetrics/botmetrics/tree/master.svg?style=svg)](https://circleci.com/gh/botmetrics/botmetrics/tree/master)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/botmetrics/botmetrics)

### [Deploy to AWS](#deploy-to-aws-with-convox)

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

## Quick Installation

You can deploy Botmetrics with one click to your Heroku account.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/botmetrics/botmetrics)

One-click deployment to Amazon AWS, Google Cloud and Microsoft Azure is
coming soon!

## Installation on your own Linux server

1. Make sure you have Ruby 2.3.1 installed along with Rubygems (make
   sure you have `libxslt-dev`, `libxml2-dev`, `libpq-dev` installed on
your machine).
2. Setup the `.env` file by running `cp .env-example .env`
3. Replace `JSON_WEB_TOKEN_SECRET` with your own randomized secret.
4. Replace `DATABASE_URL` and `REDIS_URL` with URLs to your Postgres and Redis database URLs respectively. (Postgres and Redis can be on the same machine or different machines).
5. Run `./script/server` to start the server.

## Development

1. `cp .env-example .env`
2. Start Redis & Postgres (there's a `./script/redis` and
   `./script/dbstart` command that lets you do this easily)
3. Run `./script/dbreset` to reset the database (creates a new one,
   loads schema and runs `rake db:seed`)
4. Run `./script/server` to start the server
5. Visit [localhost:3000](http://localhost:3000)

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

## Running Botmetrics with Docker Compose

1. [Install Docker](https://www.docker.com/products/overview#/install_the_platform/?utm_source=getbotmetrics.com&utm_campaign=github_docker)
2. Edit `docker-compose.yml` to update all the instances of  `JSON_WEB_TOKEN_SECRET`, REDIS_URL and DATABASE_URL
3. Get the database ready with `docker-compose run web bundle exec rake db:reset`
4. Bring up the services with `docker-compose up` in the botmetrics project directory.
5. Goto [localhost:3000](http://localhost:3000) Enjoy!

## Deploying Botmetrics to AWS with Convox

[Convox](https://www.convox.com) is an easy way to deploy dockerized applications to [AWS](http://www.aws.com)

1. Sign up for Convox, Install a Rack and Convox CLI.
2. In your botmetrics directory issue the following commands:
   `convox apps create` to create an application called botmetrics
3. `convox services create postgres && convox services create redis` this will provision a Postgres and Redis Service on AWS (Go get a coffee.)
4. Once convox has finished creating the app you can start you first deploy with `convox deploy`
5. Set the environment variables for Redis and Postgres
   1. `convox services` will list the names of the postgres and redis service instances.
   2. `convox service info <service name>` will provide the URL for each service.
   3. Use `convox env set REDIS_URL=<url_from_redis_service>` and `convox env set DATABASE_URL=<url_from_redis_service>`
   4. Note the final release ID
6. After convox deploy from step 5 has finished promote the release with the ENV variables with `convox releases promote <release_id>`
7. Setup your database for the first time with `convox run web rake db:structure:load db:seed`
8. Get the public URL for your app with `convox apps info` it's the one that's on `port 80`
9. Browse to the URL and Enjoy!