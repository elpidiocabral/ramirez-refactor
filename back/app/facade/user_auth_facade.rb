class UserAuthFacade
    def initialize(header)
      @header = header
    end

    def decode_user
      decoded = JsonWebToken.decode(@header)
      User.without(:password_digest).find(decoded[:user_id])
    end
end