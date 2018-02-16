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

  # Logger used everywhere for debugging and info
  LOGGER = Logger.new(STDOUT)

  # Main scenes folder
  SCENES_FOLDER = ENV['EASYCAST_SCENES_FOLDER'] || Path.backfind(".[config.ru]")/("scenes")

  # Public assets folder
  WEBASSETS_FOLDER = SCENES_FOLDER/('assets/webassets')

  # Let mustache know where its templates are
  Mustache.template_path = ROOT_FOLDER/("lib")

  # Whether the web assets use the compiled & versionned
  VERSIONNED_ASSETS = not(ENV['EASYCAST_VERSIONNED_ASSETS'].nil?)

end
require_relative 'easycast/error'
require_relative 'easycast/model/config'
require_relative 'easycast/model/scene'
require_relative 'easycast/model/cast'
require_relative 'easycast/model/asset'
require_relative 'easycast/model/walk'
require_relative 'easycast/controller'
