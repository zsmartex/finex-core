require "jwt"

module Finex::Auth
  class JWTAuthenticator
    property public_key : String
    property private_key : String?

    def initialize(@public_key, @private_key = nil); end

    def authenticate!(token)
      token_type, token_value = token.to_s.split(" ")

      unless token_type == "Bearer"
        raise Finex::Auth::Error.new("Token type is not provided or invalid.")
      end

      decode_and_verify_token(token_value)
    rescue error
      case error
      when Finex::Auth::Error
        raise error
      else
        raise Finex::Auth::Error.new(error.message)
      end
    end

    def encode(payload : String)
      raise ::ArgumentError.new("No private key given.") if @private_key.nil?

      JWT.encode(payload, Base64.decode_string(@private_key), JWT::Algorithm::HS256)
    end

    def decode_and_verify_token(token : String)
      payload, header = JWT.decode(token, Base64.decode_string(@public_key), JWT::Algorithm::RS256)

      payload
    rescue e : JWT::DecodeError
      raise Finex::Auth::Error.new("Failed to decode and verify JWT: #{e.message}")
    end
  end
end
