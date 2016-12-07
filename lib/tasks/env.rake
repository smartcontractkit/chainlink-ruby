namespace :env do
  task :test do
    Dotenv.overload('.env.test')
  end
end
