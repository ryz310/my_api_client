# frozen_string_literal: true

Rails.application.routes.draw do
  resources :rest, only: %i[index show create update destroy]

  get 'status/:status', to: 'status#show'
  get 'header', to: 'header#index'
  get 'error/:code', to: 'error#show'
  get 'pagination', to: 'pagination#index'
end
