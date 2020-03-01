# My API

This is the real API for integration testing with `my_api_client`.

It's built by [Ruby on Jets](https://rubyonjets.com/).

## APIs

### My Rest API

This is a simple REST API that returns a specified response.

* `GET rest`
* `GET rest/:id`
* `POST rest`
* `POST/PUT/PATCH rest/:id`
* `DELETE rest/:id`

### My Status API

This API returns arbitrary status code.

_Comming soon._

### My Error API

This API returns arbitrary error code as JSON.

_Comming soon._

## Deployment

You need to prepare following environment variables:

* `AWS_REGION`
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

For information on how to create an AWS access key and secret, see the following site:

:link: [Minimal Deploy IAM Policy \- Jets Ruby Serverless Framework](https://rubyonjets.com/docs/extras/minimal-deploy-iam/)


And execute following command:

```sh
$ bundle exec jets deploy
```
