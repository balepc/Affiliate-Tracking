require 'rake'
require 'bundler/setup'

Bundler.setup(:default, :development)


namespace :db do
  desc "Migrate database"
  task :migrate do
    require "rubygems"
    require './server'

    DataMapper.setup(:default, "postgres://#{PG_USERNAME}:#{PG_PASSWORD}@#{PG_HOST}/#{PG_DATABASE}")
    DataMapper.auto_migrate!
  end
end

