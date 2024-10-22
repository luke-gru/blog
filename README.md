# My Blog

## Setup:

* `$ bundle`
* `$ bin/rails db:setup`
* `$ npm install`

Start rails server:
* `$ bin/rails s`
Start tailwind css watch daemon
* `$ bin/rails tailwindcss:watch`

or, using Procfile, start everything (can't use debugger anymore):
* `$ bin/dev`

go to localhost:3000/admin, and sign in. Take a look at `db/seeds.rb`
for login information.
