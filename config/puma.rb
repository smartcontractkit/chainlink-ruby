workers Integer(ENV['WEB_CONCURRENCY'] || 3)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['NAYRU_PORT'] || ENV['PORT'] || 6688
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
