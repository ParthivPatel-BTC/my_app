class Conversation < Sequel::Model
  one_to_many :messages, dependent: :destroy
  many_to_one :customer

  def user
    customer.userlogin
  end
end
