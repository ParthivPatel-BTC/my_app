require 'yaml'
require 'sinatra/base'

class SinatraConciergeApp < Sinatra::Base

  set :app_file, __FILE__
  set :root, File.dirname(__FILE__)
  set :server, :puma

  configure do
    enable :cross_origin
    set :allow_origin, :any
    set :allow_methods, [:get,:post,:options,:delete,:put]
    set :allow_headers, ['*', 'Content-Type', 'Origin', 'Accept', 'X-Requested-With', 'x-xsrf-token']
    set :expose_headers, ['Content-Type']
    Sequel::Database.extension :pagination
    Sequel::Model.plugin :timestamps
    Sequel::Model.plugin :auto_validations,
      not_null: :presence, unique_opts: { only_if_modified: true }
  end

  options "*" do
      response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    200
  end



  configure :development do
    require 'sinatra/reloader'
    require 'logger'

    register Sinatra::Reloader
    Sequel.connect YAML.load_file(File.expand_path("../config/database.yml", __FILE__))['development'],
      loggers: [Logger.new($stdout)]
  end

  configure :test do
    Sequel.connect YAML.load_file(File.expand_path("../config/database.yml", __FILE__))['test']
  end

  configure :production do
    # Serve assets via Nginx or Apache
    disable :static
    Sequel.connect YAML.load_file(File.expand_path("../config/database.yml", __FILE__))['production']
  end
end
