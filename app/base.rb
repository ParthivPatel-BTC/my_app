require 'multi_json'

class Base < SinatraConciergeApp

  before do
    ensure_json_request
  end

  attr_accessor :decoded_token

  def validate_jwt
    return unauthorize_access if access_token.empty?

    @decoded_token = Auth::JWTDecoder.new(token: access_token)
    # if @decoded_token.blacklisted?
    #   @decoded_token.revoke_token
    #   render json: {errors: "The token is no longer valid."}, status: 403
    # end
  rescue JWT::ExpiredSignature
    halt 403, MultiJson.dump({message: "The token has expired"})
  rescue JWT::DecodeError # Most generic decoding error
    halt 403, MultiJson.dump({message: "The token is missing or invalid"})
  end

  def authenticated_user
    halt 401 if decoded_token.blank?
    Userlogin.find(decoded_token.jwt_user_id)
  end

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
    halt 422 unless request.env["CONTENT_TYPE"] == 'application/json'
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