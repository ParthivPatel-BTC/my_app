# Call this service from rails console to manually create conversation in Kustomer.
# Concierge::ManualKustomerConversationCreator.new(Conversation.last.id).create

module Concierge
  class ManualKustomerConversationCreator
    attr_reader :conversation_id
    attr_accessor :message_builder

    def initialize(conversation_id)
      @conversation_id = conversation_id
    end

    def create
      KustomerConversation.new(customer, message_collection, conversation_id).create_conversation
    end

    private

    def message_collection
      messages = conversation.messages
      messages.each_with_object([]) do |msg, collection|
        collection << message_payload(msg)
      end
    end

    def customer
      @customer ||= conversation.customer
    end

    def conversation
      @conversation ||= Conversation.find(conversation_id)
    end

    def message_payload(msg)
      MessagePayload.new(msg).build
    end
  end
end