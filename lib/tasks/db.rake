namespace :db do
  task :pull do |task, args|
    raise "only in development" unless Rails.env.development?
    remote_environment = ENV['remote'] || 'testnet'
    backup_id = nil

    puts "Creating remote backup..."
    Bundler.with_clean_env do
      backup_id = `heroku pg:backups capture --remote #{remote_environment} | grep backup---\\> | sed 's/^.* ---backup---> //'`.strip
    end

    puts "Copying remote backup..."
    Bundler.with_clean_env do
      `curl -G \`heroku pg:backups public-url #{backup_id} --remote #{remote_environment}\` > tmp/latest.dump`
    end

    Rake::Task['db:copy'].execute
  end

  task :copy do
    puts "Loading backup into nayru_development"
    Bundler.with_clean_env do
      `cat tmp/latest.dump | pg_restore --clean --no-owner -d nayru_development`
    end
  end

  task update: ['db:create', 'db:migrate', 'db:seed']
end

