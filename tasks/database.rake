namespace :db do
  task :migrate do
    DataMapper.setup(:default, "postgres://#{PG_USERNAME}:#{PG_PASSWORD}@#{PG_HOST}/#{PG_DATABASE}")
    DataMapper.auto_migrate!
  end
end
