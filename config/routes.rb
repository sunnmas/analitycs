require 'sidekiq/web'

Rails.application.routes.draw do
  mount API::Root, at: '/'
  mount Sidekiq::Web, at: '/jobs'
  mount GrapeSwaggerRails::Engine, at: '/swagger'

  ActiveAdmin.routes(self)
  root                                 to: 'admin/dashboard#index'
  get    'admin/login',                to: 'application#login',         as: 'login'
  delete 'admin/logout',               to: 'application#logout',        as: 'destroy_user_session'
  get    'admin/logout',               to: 'application#logout'

  post   'admin/authenticate',         to: 'application#authenticate',  as: 'authenticate'
  match	 'debug',                      to: 'application#debug',         as: 'debug', via: [:get, :post]
end
