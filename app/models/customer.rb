class Customer < Sequel::Model

  one_to_one :userlogin
  one_to_many :doctors
  one_to_many :appointment_requests
  one_to_many :misc_requests
  one_to_many :bills
  one_to_many :prescriptions
  one_to_many :conversations

  def full_name
    "#{firstname} #{lastname}"
  end

  def kustomer_conversation_id
    return if conversations.blank?

    conversations.last.kustomer_conversation_id
  end

  def create_message(msg_params)
    conversation_id = conversations.last.id
    Messages.create!(msg_params.merge(conversation_id: conversation_id))
  end
end