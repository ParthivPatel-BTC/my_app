require 'sinatra/base'
require 'multi_json'

class Base < Sinatra::Base

  before do
    ensure_json_request
  end

  attr_accessor :decoded_token

  def validate_jwt
    return unauthorize_access if access_token.blank?

    @decoded_token = Auth::JWTDecoder.new(token: access_token)

    if @decoded_token.blacklisted?
      @decoded_token.revoke_token
      render json: {errors: "The token is no longer valid."}, status: 403
    end
  rescue JWT::ExpiredSignature
    render json: {errors: "The token has expired."}, status: 403
  rescue JWT::DecodeError # Most generic decoding error
    render json: {errors: "The token is missing or invalid."}, status: 403
  end

  def authenticated_user
    halt 401 if decoded_token.blank?
    Userlogin.find(decoded_token.jwt_user_id)
  end

  # rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
  #   error = { "#{parameter_missing_exception.param}": 'parameter is required' }
  #   render json: { errors: error }, status: :bad_request
  # end

  private

  def access_token
    request.env['HTTP_ACCESS_TOKEN']
  end

  def unauthorize_access
    halt 401, MultiJson.dump({message: "You are not authorized to access this resource"})
  end

  def success_response(status: 200, message: '', data: {})
    json_response(status, message, data)
  end

  def failed_response(status: 500, message: '', data: {})
    json_response(status, message, data)
  end

  def json_response(status, message, data)
    render status: status, json: { message: message, data: data}
  end

  def logout_user; end

  def ensure_json_request
    halt 200 if request.format.json?
    halt 204
  end

  def customer
    @customer ||= authenticated_user.customer
  end

  def customer_info
    {
      first_name: customer&.firstname,
      last_name: customer&.lastname,
      gender: customer&.gender,
      date_of_birth: customer&.dob
    }
  end

  def customer_address
    {
      street: customer&.streetaddress,
      zipcode: customer&.zipcode,
      city: customer&.city,
      state: customer&.state
    }
  end
end