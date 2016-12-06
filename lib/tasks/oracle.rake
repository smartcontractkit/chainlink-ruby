namespace :oracle do
  task initialize: ['db:update'] do
    coordinator = Coordinator.first

    STDOUT.puts "\n\nReady to print coordinator credentials to the screen."
    STDOUT.puts "Are you ready? (Y/n)"
    input = STDIN.gets.strip
    if input == 'Y'
      puts "KEY:\t#{coordinator.key}"
      puts "SECRET:\t#{coordinator.secret}"
    else
      puts "OK, run again when you're ready."
    end
  end
end

