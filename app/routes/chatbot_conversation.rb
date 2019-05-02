class ChatbotConversation < Base

  before do
    validate_jwt
  end

  post '/' do
    chatbot_conversation = JSON.parse(request.body.read)['chatbot_conversation']
    # Create and save conversation and messages in database
    conversation_id = Kustomer::CreateConversation.new(customer, chatbot_conversation['steps'], chatbot_conversation['helpType']).create_new_conversation

    # Create conversation, messages and customer in Kustomer platform
    # KustomerConversationWorker.perform_async(customer.id, chatbot_conversation[:steps], conversation_id)
    # success_response

    content_type :json
  end
end