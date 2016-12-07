Rake::Task[:default].clear
task default: ['env:test', 'spec']
