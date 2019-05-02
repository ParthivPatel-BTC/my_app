class Message < Sequel::Model
  many_to_one :conversation

  def self.belonged_conversations(conversations)
    where(conversation_id: conversations.pluck(:id)).order(created_at: :asc)
  end
end
