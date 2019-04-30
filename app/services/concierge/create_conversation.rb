module Concierge
  class CreateConversation

    TABLE_HELP_MAPPING = { doctor: Doctor, prescription: Prescription, bill: Bill }.freeze
    MAPPED_COLUMNS = { bill: { billImageUrl: 'bill_image_url', billIssueExplanation: 'billing_issue' },
                          prescription: { medication: 'prescription_name', pickUpOption: 'pick_up_option', usePrefferedPharmacy: 'use_preffered_pharmacy', pharmacyName: 'pharmacy_name', deliveryTime: 'delivery_time', prescriptionUrl: 'prescription_image_url', doctorWhoPrescribed: 'doctor_who_prescribed', doctorPhone: 'doctor_phone' },
                          doctor: { doctorPreference: 'doctor_preference', healthCondition: 'health_condition', doctorExpertise: 'doctor_type', doctorGender: 'doctor_gender', doctorArea: 'doctor_address', doctorWithSpecificHospital: 'hospital', hospitalName: 'hospital',  doctorSpeakOtherLanguage: 'doctor_speak_other_language', doctorLanguage: 'doctor_language', otherInfo: 'other_info' }
                        }.freeze

    attr_reader :customer, :helptype, :steps, :userlogin_id

    def initialize(customer, steps, helptype)
      @customer = customer
      @helptype = helptype
      @steps = steps
      @userlogin_id = customer.userlogin&.id
    end

    def create_new_conversation
      steps.each do |message|
        meta_data_type = message[:metadata].present? && message[:value].present? ? message[:metadata][:dataType].to_sym : nil

        if meta_data_type.present?
          db_column = MAPPED_COLUMNS[helptype.to_sym][meta_data_type]

          resource_params[db_column] = message[:value] if db_column.present?

          message_content = resource_params[db_column]
        else
          message_content = extract_message_or_value(message)
        end
        message_params << {content: message_content, userlogin_id: userlogin_id, sender_id: sender_id(message)}
      end
      create_messages
      save_meta_data
      conversation.id
    end

    def save_meta_data
      # Save extracted data in the relative tables
      resource_params[:customer_id] = customer.id
      TABLE_HELP_MAPPING[helptype.to_sym].create!(resource_params)
    end

    private

    def resource_params
      @resource_params ||= {}
    end

    def conversation
      @conversation ||= Conversation.create!(customer_id: customer.id)
    end

    def message_params
      @message_params ||= []
    end

    def extract_message_or_value(msg)
      msg.key?('value') ? msg['value'] : msg['message']
    end

    def sender_id(message)
      customer.id if message['value'].present?
    end

    def create_messages
      conversation.messages.create!(message_params)
    end
  end
end