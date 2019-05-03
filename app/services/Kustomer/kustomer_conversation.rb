require_relative '../../../app/models/conversation.rb'
require_relative '../../../app/services/Kustomer/kustomer_api_client.rb'
require_relative '../../../app/services/Kustomer/kustomer_message_payload.rb'
require 'active_model_serializers'

module Kustomer
  class KustomerConversation

    attr_reader :customer, :conversation_steps, :conversation_id

    def initialize(customer, conversation_steps, conversation_id)
      @customer = customer
      @conversation_steps = conversation_steps
      @conversation_id = conversation_id
    end

    def create_conversation
      # Update Kustomer conversation id in database
      conversation.update(kustomer_conversation_id: kustomer_conversation_id)

      conversation_steps.each do |msg|
        # Push messages to Kustomer
        Kustomer::KustomerApiClient.create_message(message(msg), kustomer_conversation_id)
      end
      conversation.update(submitted_to_kustomer: true)
    rescue => e
      puts "=======>#{e.inspect}"
      conversation.update(submitted_to_kustomer: false)
      # ExceptionHandler.capture_exception(e, extra_context)
    end

    private

    def kustomer_id
      # Create new conversation on Kustomer platform
      find_or_create_kustomer
    end

    def conversation
      @conversation ||= Conversation[conversation_id]
    end

    def kustomer_conversation_id
      @kustomer_conversation_id ||= find_or_create_conversation
    end

    def find_or_create_conversation
      return konversation_id if konversation_id.present?

      Kustomer::KustomerApiClient.create_conversation(conversation_steps, kustomer_id)
    end

    def find_or_create_kustomer
      return customer.kustomer_id if customer_persist?

      Kustomer::KustomerApiClient.create_new_customer(customer)
    end

    def customer_persist?
      customer.kustomer_id.present? && Kustomer::KustomerApiClient.customer_on_kustomer?(customer)
    end

    def konversation_id
      @konversation_id ||= Kustomer::KustomerApiClient.fetch_conversation(kustomer_id)
    end

    def message(msg)
      Kustomer::KustomerMessagePayload.new(msg).build.to_json
    end

    def extra_context
      {conversation_id: conversation.id}
    end
  end
end