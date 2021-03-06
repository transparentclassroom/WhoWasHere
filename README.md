# WhoWasHere

This is a rails app that works as a heroku log drain and tracks user visits to the site.

Currently, it doesn't do much else, except serve up sparklines.

It lives at https://whowashere.herokuapp.com/

## Use Cases

* Heroku pushes logs into WhoWasHere as a [log drain](https://devcenter.heroku.com/articles/log-drains) via the `POST /logs` endpoint.
* We can retrieve sparkline data for multiple users via the `/api/schools/X/sparklines?id[]=1&id[]=2&id=...` endpoint.
* We can go to `/schools/X/visits` and `/users/X/visits` to see the urls that a user or school has hit in the last 2 weeks.

To login, we use google oauth. Anyone w/ a transparentclassroom.com address may log in.

### What about the logs?

Logs are uploaded monthly to S3. To download them, look at [Downloading Logs](https://github.com/transparentclassroom/TransparentClassroom/blob/master/doc/downloading_logs.md)

## Contributing

### Running locally

It's just a rails app. `rails s` will start it on `http://localhost:5000`

The first time, you'll need to create a database and set it all up:

```
rake db:create db:migrate db:seed
```

### Running tests

`rake` will run all tests
