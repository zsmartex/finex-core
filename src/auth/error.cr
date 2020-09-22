module Finex::Auth
  # Error repesent all errors that can be returned from Auth module.
  class Error < Finex::Error
    # @return [String, JWT::*] Reason store underlying reason for given error.
    #
    # @see https://github.com/jwt/ruby-jwt/blob/master/lib/jwt/error.rb List of JWT::* errors.
    property reason : String?

    def initialize(@reason = nil)
      super(
        code: 2001,
        text: "Authorization failed".tap { |t| t + ": #{reason}" if reason },
      )
    end
  end
end
