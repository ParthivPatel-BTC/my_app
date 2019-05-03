require 'httparty'
require 'aws-sdk-s3'
require_relative '../../../app/services/kustomer/kustomer_api_client.rb'
require_relative '../../../config/aws.rb'

module Kustomer
  class Attachment

    MINUTES_20 = 604800

    attr_reader :msg

    def initialize(msg)
      @msg = msg
    end

    def create_in_kustomer
      KustomerApiClient.send_image_to_kustomer(kustomer_attachment['meta']['upload'], tempfile)

      {
        attachments: [
          {
            _id: kustomer_attachment['data']['id'],
            name: File.basename(tempfile.path),
            contentType: 'image/jpg',
            contentLength: tempfile.size
          }
        ]
      }
    end

    private

    def tempfile
      # Get image from AWS s3 using aws attachment key.
      # Get tempfile in response
      @tempfile ||= download_image_from_s3(msg['value'])
    end

    def kustomer_attachment
      # Upload image to Kustomer s3 using the paramas returned
      @kustomer_attachment ||= KustomerApiClient.create_attachment(tempfile)
    end

    def download_image_from_s3(value)
      # value is s3 url. Extract key from it.
      s3_key = value.split(UtilConstants::S3_URL).last

      presigned_url = presign_url(s3_key)

      temp_img_file = Tempfile.new(s3_key)
      temp_img_file.binmode
      temp_img_file.write HTTParty.get(presigned_url).parsed_response
      temp_img_file.rewind
      temp_img_file
    end

    def presign_url(s3_key)
      S3_CONCIERGEREQUEST_BUCKET.object(s3_key).presigned_url(:get, expires_in: MINUTES_20)
    end
  end
end