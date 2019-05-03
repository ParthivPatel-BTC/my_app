# frozen_string_literal: true
require_relative '../../../app/services/kustomer/attachment.rb'

module Kustomer
  class KustomerMessagePayload

    attr_reader :msg

    IMAGE_ATTRIBUTES = %i[billImageUrl prescriptionUrl].freeze

    def initialize(msg)
      @msg = msg
    end

    def build
      if message_contains_attachment?
        attachment_payload
      else
        generic_attributes.merge(preview: preview)
      end
    end

    private

    def attachment_payload
      attachment = Attachment.new(msg).create_in_kustomer
      generic_attributes.merge(attachment)
    end

    def preview
      msg.key?('value') ? msg['value'] : msg['message']
    end

    def message_contains_attachment?
      msg.key?('metadata') && IMAGE_ATTRIBUTES.include?(msg['metadata']['dataType'].to_sym)
    end

    def direction
      msg.key?("value") ? 'in' : 'out'
    end

    def generic_attributes
      {
        app: "JOANY",
        channel: "chat",
        subject: "Chat",
        direction: direction
      }
    end
  end
end