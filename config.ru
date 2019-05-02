require File.expand_path('../config/boot.rb', __FILE__)
require BASE_PATH + '/sinatra_concierge_app'
require BASE_PATH + '/config/autoloader'

run SinatraConciergeApp

map('/api/v1/chatbot-conversation') { run ChatbotConversation }
