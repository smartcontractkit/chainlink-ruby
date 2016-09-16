namespace :delayed_jobs do
  task clear: [:environment] do |task, args|
    puts "Starting with #{Delayed::Job.count} stuck jobs"
    Delayed::Job.where("last_error IS NOT null").pluck(:id).each do |djid|
      begin
        dj = Delayed::Job.find(djid)
        dj.invoke_job
        puts "destroying #{dj.handler}"
        dj.destroy
      rescue
        puts "keeping #{dj.handler}"
        next
      end
    end
    puts "Ending with #{Delayed::Job.count} stuck jobs"
  end
end

