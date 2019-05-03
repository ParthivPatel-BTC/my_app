require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/web'
require 'dotenv'
Dotenv.load('local.env')
require_relative '../base.rb'
require_relative '../../lib/workers/kustomer_conversation_worker.rb'

class ChatbotConversation < Base

  before do
    validate_jwt
  end

  post '/chatbot-conversation' do

    chatbot_conversation = params[:chatbot_conversation]

    # Create and save conversation and messages in database
    conversation_id = Kustomer::CreateConversation.new(customer, chatbot_conversation[:steps], chatbot_conversation[:helpType]).create_new_conversation

    # Create conversation, messages and customer in Kustomer platform
    KustomerConversationWorker.perform_async(customer.id, chatbot_conversation[:steps], conversation_id)
    # success_response

    content_type :json
  end
end