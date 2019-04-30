module BaseApi

  # skip_before_action :verify_authenticity_token
  # before_filter :ensure_json_request
  module_function

  attr_accessor :decoded_token

  def validate_jwt(access_token)
    return unauthorize_access if access_token.nil?

    @decoded_token = JWTDecoder.new(token: access_token)

    if @decoded_token.blacklisted?
      @decoded_token.revoke_token
      {errors: "The token is no longer valid."}.to_json
    end
  rescue JWT::ExpiredSignature
    {errors: "The token has expired."}.to_json
  rescue JWT::DecodeError # Most generic decoding error
    {errors: "The token is missing or invalid."}.to_json
  end

  def authenticated_user
    return if decoded_token.blank?
    Userlogin.find(decoded_token.jwt_user_id)
  end

  # rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
  #   error = { "#{parameter_missing_exception.param}": 'parameter is required' }
  #   render json: { errors: error }, status: :bad_request
  # end

  # private

  # def access_token(access_token)
  #   access_token
  # end

  def unauthorize_access
    render json: {errors: 'The token is missing.'}, status: 403
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
    return if request.format.json?
    render nothing: true, status: :not_acceptable
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
