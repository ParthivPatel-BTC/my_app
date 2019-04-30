require File.expand_path('../config/boot.rb', __FILE__)
require SinatraConciergeApp::ROOT + '/sinatra_concierge_app'
require SinatraConciergeApp::ROOT + '/config/application'

run SinatraConciergeApp
