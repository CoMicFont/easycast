namespace :test do

  require "rspec/core/rake_task"

  desc "Run unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/**/test_*.rb"
    t.rspec_opts = ["--color", "--backtrace", "--fail-fast"]
  end

end
task :test => [:'test:unit']
