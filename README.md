# My Blog

## Server dependencies:

* Unix server environment
* ruby >= 3.2, older versions might work (untested)
* redis-server >= 6.2.0 (for background jobs)
* sqlite3
* Nodejs + npm
* docker, curl and git
* sshd

## Development dependencies:

All server dependencies except sshd. Docker is optional.

## Development Setup:

* `$ bundle`
* `$ bin/rails db:setup`

Start rails server:

`$ bin/rails s`

Start tailwind css watch daemon

`$ bin/rails tailwindcss:watch`

Make sure redis-server is running

`$ ps aux | grep redis-server`

Start sidekiq job runner

`$ sidekiq`

or, using Procfile, start everything (but can't use debugger on the server anymore):

`$ bin/dev`

go to localhost:3000/admin, and sign in. Take a look at `db/seeds.rb`
for login information.

## Development using docker

Alternatively you can use the docker setup in docker-compose-dev.yml:

Specify redis host in .env file:
REDIS_HOST=redis

To start all services:

`$ docker compose up -d`

You still need to run `bin/rails tailwindcss:watch`. This doesn't need to be run
from the container, as there's a docker bind-mount b/t the 2 directories

To watch the server logs and allow using debugger on the app server:

Find webapp docker container id
> docker ps | grep server_ent | awk '{ print $1 }'
> docker attach THIS_ID

Put them together:
> docker attach $(docker ps | grep server_ent | awk '{ print $1 }')

To detach: <CTRL-p> <CTRL-q>

Use bin/run to run commands in the docker webapp container, ex: `./bin/run console`
If you get permissions errors, make sure a docker group has been created and setup.

## Deployment

Deployment uses kamal. Needs docker engine to be installed locally.

