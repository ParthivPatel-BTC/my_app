require_relative '../../app/models/customer.rb'
require_relative '../../app/services/Kustomer/kustomer_conversation.rb'

class KustomerConversationWorker
  include Sidekiq::Worker
  # include WorkerConfigs

  def perform(customer_id, steps, conversation_id)
    return if conversation_id.nil?

    customer = Customer[customer_id]
    Kustomer::KustomerConversation.new(customer, steps, conversation_id).create_conversation
  end
end