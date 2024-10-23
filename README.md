# My Blog

## Server dependencies:

* Unix server environment
* ruby >= 3.2, older versions might work (untested)
* redis-server >= 6.2.0 (for background jobs)
* sqlite3

## Dev dependencies:

All server dependencies, plus:

* nodejs
* npm

## Setup:

* `$ bundle`
* `$ bin/rails db:setup`
* `$ npm install`

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
