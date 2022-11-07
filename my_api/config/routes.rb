# frozen_string_literal: true

Jets.application.routes.draw do
  root 'jets/public#show'

  resources 'rest', only: %i[index show create update delete]

  get 'status/:status', to: 'status#show'
  get 'header', to: 'header#index'
  get 'error/:code', to: 'error#show'
  get 'pagination', to: 'pagination#index'

  # The jets/public#show controller can serve static utf8 content out of the public folder.
  # Note, as part of the deploy process Jets uploads files in the public folder to s3
  # and serves them out of s3 directly. S3 is well suited to serve static assets.
  # More info here: https://rubyonjets.com/docs/extras/assets-serving/
  any '*catchall', to: 'jets/public#show'
end
