require 'path'
require 'finitio'
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'mustache'
require 'rack/nocache'
module Easycast

  # Version of Easycast software
  VERSION = "1.0.0"

  # Root folder of the project structure
  ROOT_FOLDER = Path.backfind('.[Gemfile]') or raise("Missing Gemfile")

  # Public folder
  PUBLIC_FOLDER = ROOT_FOLDER/('public')

  # Public assets folder
  PUBLIC_ASSETS_FOLDER = PUBLIC_FOLDER/('assets')

  LOGGER = Logger.new(STDOUT)

  SCENES_FOLDER = ENV['EASYCAST_SCENES_FOLDER'] || Path.backfind(".[config.ru]")/("scenes")

  Mustache.template_path = ROOT_FOLDER/("lib")

end
require_relative 'easycast/error'
require_relative 'easycast/model/config'
require_relative 'easycast/model/scene'
require_relative 'easycast/model/cast'
require_relative 'easycast/model/asset'
require_relative 'easycast/model/walk'
require_relative 'easycast/controller'
