# frozen_string_literal: true

module UtilConstants
  ATTACHMENT = 'amazonaws'
  S3_URL = 's3.amazonaws.com/'
  HELLEN_IMAGE = 'https://www.socaltech.com/images/story/helenlee2017.png'
  BOT_ID = 1
  KUSTOMER_ERRORS = [Net::OpenTimeout, Errors::KustomerErrors, RestClient::Exceptions::Timeout].freeze
end