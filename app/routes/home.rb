require './app/base_api.rb'

class MyApp
  post '/api/v1/chatbot-conversation' do
    BaseApi.validate_jwt(request.env['HTTP_ACCESS_TOKEN'])
    chatbot_conversation = params[:chatbot_conversation]

    # Create and save conversation and messages in database
    conversation_id = Concierge::CreateConversation.new(customer, chatbot_conversation[:steps], chatbot_conversation[:helpType]).create_new_conversation

    # Create conversation, messages and customer in Kustomer platform
    # KustomerConversationWorker.perform_async(customer.id, chatbot_conversation[:steps], conversation_id)
    # success_response

    content_type :json

  end
end
