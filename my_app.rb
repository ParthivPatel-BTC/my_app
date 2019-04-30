require 'yaml'

class MyApp < Sinatra::Application
  use Rack::Session::EncryptedCookie,
    secret: '4d1670892fee9296ead2fc2d2414b50fad1f4a69ff7c27c28a2bac062cb4dc8d'

  set :app_file, __FILE__
  set :server, :puma
  set :views, Proc.new { File.join(root, "app/views") }
  set :assets, Sprockets::Environment.new
  set :assets_manifest, %w(app.js app.css)
  # use Rack::Csrf, raise: true

  configure do
    Sequel::Database.extension :pagination
    Sequel::Model.plugin :timestamps
    Sequel::Model.plugin :auto_validations,
      not_null: :presence, unique_opts: { only_if_modified: true }

    assets.append_path 'assets/stylesheets'
    assets.append_path 'assets/javascripts'
  end

  configure :development do
    require 'sinatra/reloader'
    require 'logger'

    register Sinatra::Reloader
    Sequel.connect YAML.load_file(File.expand_path("../config/database.yml", __FILE__))['development'],
      loggers: [Logger.new($stdout)]

    get '/assets/*' do
      env['PATH_INFO'].sub!('/assets', '')
      settings.assets.call(env)
    end
  end

  configure :test do
    Sequel.connect YAML.load_file(File.expand_path("../config/database.yml", __FILE__))['test']
  end

  configure :production do
    # Serve assets via Nginx or Apache
    disable :static

    assets.js_compressor  = :uglify
    assets.css_compressor = :sass
    Sequel.connect YAML.load_file(File.expand_path("../config/database.yml", __FILE__))['production']
  end
end
