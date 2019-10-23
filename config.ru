$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'easycast'
require 'easycast/service'
run Easycast::Service
