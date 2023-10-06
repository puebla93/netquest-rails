class Api::V1::UsersController < ApplicationController
    before_action :set_user, only: [:login]

    def signin
        user_data= {
            email: auth_params[:email],
            hashed_password: BCrypt::Password.create(auth_params[:password])
        }
        @user = Api::V1::User.new(user_data)

        if @user.save
            Rails.logger.debug("Created user with id #{@user.id}")
            render json: @user, status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end

    def login
        if @user.nil? || BCrypt::Password.new(@user.hashed_password) != auth_params[:password]
            response.headers['WWW-Authenticate'] = 'Bearer'
            return render json: {detail: 'Incorrect email or password'}, status: :unauthorized
        end

        render json: {"jwt": @user.jwt, "token_type": "bearer"}
    end

    private

    def auth_params
        params.require(:email)
        params.require(:password)
        params.permit(:email, :password)
    end

    def set_user
        @user = Api::V1::User.find_by(email: params[:email])
    end
end
