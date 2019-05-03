require 'sidekiq/web'
require 'dotenv'

Dotenv.load('local.env')

require File.expand_path('../config/boot.rb', __FILE__)
require BASE_PATH + '/sinatra_concierge_app'
require BASE_PATH + '/config/autoloader'
require BASE_PATH + '/config/aws'

run SinatraConciergeApp
run Rack::URLMap.new('/sidekiq' => Sidekiq::Web)

map('/api/v1/') { run ChatbotConversation }

