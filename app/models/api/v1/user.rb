class Api::V1::User < ApplicationRecord
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true

    def jwt
        to_encode = {
            "user_id": self.id,
            "exp": Time.now.utc.to_i + Rails.application.credentials.access_token_expire_minutes * 60,
        }
        access_token = JWT.encode(
            to_encode, Rails.application.credentials.secret_key, Rails.application.credentials.algorithm
        )

        access_token
    end
end
