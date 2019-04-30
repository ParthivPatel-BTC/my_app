require File.expand_path('../config/boot.rb', __FILE__)
require BASE_PATH + '/sinatra_concierge_app'
require BASE_PATH + '/config/application'

run SinatraConciergeApp
