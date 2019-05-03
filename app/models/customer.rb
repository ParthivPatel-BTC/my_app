class Customer < Sequel::Model
  # crypt_keeper :ssn, encryptor: :active_support, key: ENV.fetch('CRYPT_KEEPER_KEY'), salt: ENV.fetch('CRYPT_KEEPER_SALT')

  # CUSTOMER_TYPE = %w[primary spouse child other].freeze
  # PRIMARY_CUSTOMER = 'primary'.freeze
  # SPOUSE_CUSTOMER = 'spouse'.freeze
  # CHILD_CUSTOMER = 'child'.freeze

  one_to_one :userlogin, dependent: :destroy
  one_to_one :checking_account, dependent: :destroy
  one_to_many :doctors
  one_to_many :appointment_requests
  one_to_many :misc_requests
  one_to_many :bills
  one_to_many :prescriptions
  one_to_many :recommendations
  one_to_many :customer_enrollments, dependent: :destroy
  one_to_many :enrollments, through: :customer_enrollments, dependent: :destroy
  one_to_many :conversations, dependent: :destroy

  # TODO : Add validation for email & dob after data migration
  #validates :customer_type, :firstname, :lastname, presence: true
  # validates :customer_type, inclusion: { in: CUSTOMER_TYPE,
  #                                        message: "%{value} is not a valid customer type" }

  # scope :primary, -> { where(customer_type: PRIMARY_CUSTOMER) }

  # def spouse
  #   current_enrollment&.customers&.where(customer_type: SPOUSE_CUSTOMER)
  # end

  # def children
  #   current_enrollment&.customers&.where(customer_type: CHILD_CUSTOMER)
  # end

  # def current_enrollment
  #   enrollments.where(year: Settings.data_year).last
  # end

  # def full_name
  #   "#{firstname} #{lastname}"
  # end

  # def kustomer_conversation_id
  #   return if conversations.blank?

  #   conversations.last.kustomer_conversation_id
  # end

  # def self.create_and_return_info(customer_details, referrer_id)
  #   customer_info = {customer_ids: [], primary_customer_id: nil}
  #   customer_details.each do |customer_detail|
  #     next if customer_detail.blank?
  #     customer = new.upsert!(customer_detail)
  #     customer_info[:customer_ids] << customer.id
  #     if customer.customer_type == PRIMARY_CUSTOMER
  #       customer_info[:primary_customer_id] = customer.id
  #       # Create User/Userlogin for primary customer only
  #       ::UserCreator.new(email: customer.email, referrer_id: referrer_id, customer_id: customer.id).create!
  #     end
  #   end
  #   customer_info
  # end

  # def upsert!(customer_detail)
  #   customer_params = required_params(customer_detail)
  #   customer = Customer.where('email ILIKE ? AND customer_type =? AND dob =? AND firstname ILIKE ? AND lastname ILIKE ?', customer_params[:email], customer_params[:customer_type], customer_params[:dob], customer_params[:firstname], customer_params[:lastname]).last
  #   if customer.present?
  #     customer.update_attributes(customer_params)
  #     customer
  #   else
  #     Customer.create!(customer_params)
  #   end
  # end

  # def required_params(customer_detail)
  #   {
  #     email:          customer_detail[:email]&.strip,
  #     customer_type:  customer_detail[:type]&.strip&.downcase,
  #     firstname:      customer_detail[:firstName]&.strip,
  #     lastname:       customer_detail[:lastName]&.strip,
  #     middlename:     customer_detail[:middlename]&.strip,
  #     dob:            date_parser(customer_detail[:birthDate]&.strip),
  #     gender:         customer_detail[:gender]&.strip,
  #     ssn:            customer_detail[:socialSecurityNumber]&.strip,
  #     citizenship:    customer_detail[:citizenship]&.strip,
  #     streetaddress:  customer_detail[:streetAddress]&.strip,
  #     city:           customer_detail[:city]&.strip,
  #     zipcode:        customer_detail[:zipcode]&.strip,
  #     state:          customer_detail[:state]&.strip,
  #     phone:          customer_detail[:phoneNumber]&.strip
  #   }
  # end

  # def self.find_by_name_or_contact_details(enrollment_params)
  #   if enrollment_params['customerEmailAddress'].present?
  #     profile = fetch_by_email(enrollment_params['customerEmailAddress'])
  #     return profile if profile.present?
  #   end

  #   if enrollment_params['primaryName'].present?
  #     profile = find_by_name(enrollment_params['primaryName'])
  #     return profile if profile.present?
  #   end

  #   if enrollment_params['customerPhoneNumber'].present?
  #     profile = find_by_phone(enrollment_params['customerPhoneNumber'])
  #     return profile if profile.present?
  #   end
  # end

  # def self.fetch_by_email(email)
  #   Customer.where('email ILIKE (?) AND customer_type =?', email&.strip, PRIMARY_CUSTOMER).first
  # end

  # def self.find_by_phone(phone_number)
  #   Customer.where('phone_number =? AND customer_type =?', phone_number&.strip, PRIMARY_CUSTOMER).first
  # end

  # def self.find_by_name(full_name)
  #   firstname, lastname = full_name.split(' ')

  #   Customer.where('firstname ILIKE ? AND lastname ILIKE ? AND customer_type =?', firstname&.strip, lastname&.strip, PRIMARY_CUSTOMER).first
  # end

  # def date_parser(date)
  #   Date.parse(date).to_s rescue nil
  # end

  # def create_message(msg_params)
  #   conversations.last.messages.create!(msg_params)
  # end
end