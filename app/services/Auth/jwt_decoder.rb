module Auth
  class JWTDecoder
    attr_reader :decoded_token, :jwt_user_id

    def initialize(token:)
      @encoded_token = token
      @decoded_token = decode_token
      @jwt_user_id = decoded_token["sub"]
    end

    def blacklisted?
      JwtBlacklist.where(jti: decoded_token["jti"]).exists?
    end

    def revoke_token
      JwtBlacklist.create(jti: decoded_token["jti"], exp: Time.current)
    end

    private

    def decode_token
      # Set the boolean to true to raise error if the token is invalid
      jwt_raw = JWT.decode(@encoded_token, JwtConstants::HMAC_SECRET, true, algorithm: JwtConstants::JWT_SIGNING_ALGORITHM)
      jwt_raw[0]
    end
  end
end
