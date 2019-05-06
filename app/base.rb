# frozen_string_literal: true

require 'multi_json'
require_relative '../sinatra_concierge_app.rb'

class Base < SinatraConciergeApp
  before do
    content_type 'application/json'
    params.merge!(JSON.parse(request.body.read))
  end

  attr_accessor :decoded_token

  def validate_jwt
    return unauthorize_access if access_token.nil?

    @decoded_token = Auth::JWTDecoder.new(token: access_token)
    if @decoded_token.blacklisted?
      @decoded_token.revoke_token
      failed_response(status: 403, message: 'The token is no longer valid.')
    end
  rescue JWT::ExpiredSignature
    failed_response(status: 403, message: 'The token has expired')
  rescue JWT::DecodeError # Most generic decoding error
    failed_response(status: 403, message: 'The token is missing or invalid')
  end

  def authenticated_user
    halt 401 if decoded_token.nil?
    Userlogin[decoded_token.jwt_user_id]
  end

  private

  def access_token
    request.env['HTTP_ACCESS_TOKEN']
  end

  def unauthorize_access
    halt 401, MultiJson.dump(message: 'You are not authorized to access this resource')
  end

  def success_response(status: 200, message: '', data: {})
    json_response(status, message, data)
  end

  def failed_response(status: 500, message: '', data: {})
    json_response(status, message, data)
  end

  def json_response(status, message, data)
    halt status, MultiJson.dump(message: message, data: data)
  end

  def ensure_json_request
    halt 422 unless request.env['CONTENT_TYPE'] == 'application/json'
  end

  def customer
    @customer ||= authenticated_user.customer
  end
end
