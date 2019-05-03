class Userlogin < Sequel::Model
  # attr_accessor :tracking_parameter, :pennyhoarder_transaction_id
  # # Include default devise modules. Others available are:
  # # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable

  # before_create :set_uuid, :generate_token_first, :set_share_token
  one_to_many :recommendations
  many_to_one :customer

  # def send_devise_notification(notification, *args)
  #   devise_mailer.send(notification, self, *args).deliver_later
  # end

  # def info_up_to_date?
  #   # anyone that's come through to update their data after sep 16th 2017
  #   recommendations.present? && (recommendations.last.updated_at.to_date > Date.new(2017, 9, 16)) && recommendations.last.income.present?
  # end

  # # def is_currently_enrolled?
  # #   # TODO: - change the hardcoded year away from simply '2018'
  # #   if user_profile.present? && user_profile.plan_id.present?
  # #     eob = Eob.find_by(plan_id: user_profile.plan_id)
  # #     eob && eob.year == 2018 ? true : false
  # #   else
  # #     false
  # #   end
  # # end

  # # Use the below for email token matching now!
  # #
  # # From the email we want to pass the salted_token & the user uuid or email
  # # Example:
  # # user = User.where(uuid: params[:uuid])
  # # user.salted_token == params[:salted_token]
  # SUPER_SECRET_SHARED = "h_7*sFCx{P7!wtU5~fHCQ`_\_M'L\.a/"

  # def salted_token
  #   self.class.salted_token(uuid: self.uuid)
  # end

  # def self.salted_token(uuid:)
  #   raise ArgumentError if uuid.blank?
  #   Digest::SHA256.hexdigest("#{uuid}#{SUPER_SECRET_SHARED}")
  # end

  # def generate_token_first
  #   begin
  #     self[:auth_token] = SecureRandom.urlsafe_base64
  #   end while Userlogin.exists?(:auth_token => self[:auth_token])
  # end

  # def generate_token(column)
  #   begin
  #     self[column] = SecureRandom.urlsafe_base64
  #   end while Userlogin.exists?(column => self[column])
  # end

  # def send_password_reset
  #   unless reset_password_token.present?
  #     generate_token(:reset_password_token)
  #     self.reset_password_sent_at = Time.zone.now
  #     save!
  #   end
  #   EobMailer.send_password_reset(self).deliver_later
  # end

  # def upadte_share_token
  #   update!(share_token: ShareToken.new(email: email).to_s)
  # end

  # def set_reset_pw_token_only
  #   generate_token(:reset_password_token)
  #   self.reset_password_sent_at = Time.zone.now
  #   save!
  # end

  # private

  # def set_uuid
  #   self.uuid = SecureRandom.uuid unless uuid
  # end

  # def set_share_token
  #   self.share_token = ShareToken.new(email: self.email).to_s
  # end
end