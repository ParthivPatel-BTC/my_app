module Auth
  class JWTGenerator
    attr_reader :token, :expiration_in_seconds, :jti

    def initialize(userlogin:)
      @userlogin = userlogin
      @token = generate_token
    end

    private

    def generate_token
      JWT.encode(payload, JwtConstants::HMAC_SECRET, JwtConstants::JWT_SIGNING_ALGORITHM)
    end

    def payload
      { sub: @userlogin.id, jti: jwt_id }
    end

    def jwt_id
      jti_raw = [JwtConstants::HMAC_SECRET, issued_at_time].join(':').to_s
      @jti = Digest::MD5.hexdigest(jti_raw)
    end

    def issued_at_time
      Time.now.utc.to_i
    end

    def expiration
      Time.now.to_i + JwtConstants::JWT_EXPIRATION_IN_SECONDS
    end
  end
end