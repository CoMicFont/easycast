require 'path'

#
# Install all tasks found in tasks folder
#
# See .rake files there for complete documentation.
#
Dir["tasks/*.rake"].each do |taskfile|
  load taskfile
end

task :require do
  $:.unshift File.expand_path('../lib', __FILE__)
  require 'easycast'
  require 'uglifier'
  include Easycast
end

task :default => :test
