module Kustomer
  class KustomerApiClient
    include HTTParty
    BASE_API = 'https://api.kustomerapp.com/v1'.freeze
    HEADERS = {'Content-Type': 'application/json', "Authorization": "Bearer #{UtilConstants::KUSTOMER_API_AUTH_TOKEN}"}.freeze

    RETRY_HANDLER = Proc.new do |exception, attempt_number, total_delay|
      Rails.logger.debug "Handler saw a #{exception.class}; retry attempt #{attempt_number}; #{total_delay} seconds have passed."
    end
    RETRY_OPTIONS = { base_sleep_seconds: 2, max_sleep_seconds: 5, rescue: UtilConstants::KUSTOMER_ERRORS, handler: RETRY_HANDLER, max_tries: 2 }.freeze

    # Create new kustomer conversation
    def self.create_conversation(conversation_steps, kustomer_id)
      resp = HTTParty.post("#{BASE_API}/customers/#{kustomer_id}/conversations", body: conversion_detail(conversation_steps).to_json, headers: HEADERS)
      raise Errors::KustomerErrors.new(resp['errors']) if resp['errors'].present?
      customer_response_id(resp.body)
    end

    def self.create_message(message, conversation_id)
      resp = HTTParty.post("#{BASE_API}/conversations/#{conversation_id}/messages", body: message, headers: HEADERS)
      raise Errors::KustomerErrors.new(resp['errors']) if resp['errors'].present?
    end

    def self.create_new_customer(customer)
      resp = HTTParty.post("#{BASE_API}/customers", body: customer_detail(customer).to_json, headers: HEADERS)
      raise Errors::KustomerErrors.new(resp['errors']) if resp['errors'].present?
      customer_id = customer_response_id(resp.body)
      customer.update(kustomer_id: customer_id)
      customer_id
    end

    def self.customer_on_kustomer?(customer)
      resp = HTTParty.get("#{BASE_API}/customers/#{customer.kustomer_id}", headers: HEADERS)
      resp.response.code == '200'
    end

    def self.create_attachment(image)
      resp = HTTParty.post("#{BASE_API}/attachments", body: attachment_detail(image).to_json, headers: HEADERS)
      raise Errors::KustomerErrors.new(resp['errors']) if resp['errors'].present?
      JSON.parse(resp.body)
    end

    def self.send_image_to_kustomer(attachment_json, image)
      RestClient.post(
        attachment_json['url'],
        attachment_fields(attachment_json['fields'], image),
        headers: { Authorization: "Bearer #{UtilConstants::KUSTOMER_API_AUTH_TOKEN}" }
      )
    end

    def self.fetch_conversation(kustomer_id)
      resp = HTTParty.get("#{BASE_API}/customers/#{kustomer_id}/conversations?page=1&pageSize=1", headers: HEADERS)
      raise Errors::KustomerErrors.new(resp['errors']) if resp['errors'].present?
      parsed_response = JSON.parse(resp.body)
      parsed_response['data'].first&.[]('id')
    end

    def self.attachment_fields(attachment_json, image)
      {
        "key": attachment_json['key'],
        "acl": attachment_json['acl'],
        "Content-Type": attachment_json['Content-Type'],
        "X-Amz-Meta-Attachment-Id": attachment_json['X-Amz-Meta-Attachment-Id'],
        "bucket": attachment_json['bucket'],
        "X-Amz-Algorithm": attachment_json['X-Amz-Algorithm'],
        "X-Amz-Credential": attachment_json['X-Amz-Credential'],
        "X-Amz-Date": attachment_json['X-Amz-Date'],
        "Policy": attachment_json['Policy'],
        "X-Amz-Signature": attachment_json['X-Amz-Signature'],
        "file": image,
        "multipart": true
      }
    end

    def self.attachment_detail(image)
      {
        name: "#{File.basename(image.path)}.jpg",
        contentType: "image/jpg",
        contentLength: image.size
      }
    end

    def self.conversion_detail(conversation_steps)
      {
        name: conversation_steps.first['message'],
        status: "open",
        direction: "in"
      }
    end

    def self.customer_detail(customer)
      {
        name: customer.full_name,
        emails: [
          {
            type: "work",
            email: customer.email
          }
        ],
        phones: [
          {
            type: "work",
            phone:  customer.phone
          }
        ],
        locations: [
          {
            type: "work",
            address: "#{customer.streetaddress} #{customer.city} #{customer.state} #{customer.zipcode}"
          }
        ]
      }
    end

    def self.customer_response_id(api_response)
      parsed_response = JSON.parse(api_response)
      parsed_response["data"]["id"]
    end
  end
end