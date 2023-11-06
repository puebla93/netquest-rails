class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Implement your authentication logic here
    # For example, check for a valid API key in the request headers

    token = nil
    user = nil

    if auth_header = env['HTTP_AUTHORIZATION']
      # Get token from the header
      token = auth_header.split()[1]
      if token.nil?
        Rails.logger.error("Invalid Authorization header: #{auth_header}")
        return [401, { 'WWW-Authenticate' => 'Bearer' }, ['Could not validate credentials']]
      end

      begin
        user = handle_token(token)
      rescue Exception
        return [401, { 'WWW-Authenticate' => 'Bearer' }, ['Could not validate credentials']]
      end
    end

    env['user'] = user

    # If authentication is successful, pass the request to the next middleware
    @app.call(env)
  end

  private

  def handle_token(token)
    # Implement your API key validation logic here
    # This is just a placeholder, replace it with your actual logic
    begin
      decoded_token = JWT.decode(
        token,
        Rails.application.credentials.secret_key,
        true,
        algorithm: Rails.application.credentials.algorithm
      )
      payload = decoded_token[0]
    rescue JWT::DecodeError => exc
      Rails.logger.error "JWT Decode Error: #{exc.message}"
      raise exc
    rescue JWT::VerificationError => exc
      Rails.logger.error "JWT Verification Error: #{exc.message}"
      raise exc
    end

    user_id = payload['user_id']
    unless user_id
      Rails.logger.error "INVALID_JWT_TOKEN: User id not found in token payload #{payload}"
      raise Exception "INVALID_JWT_TOKEN: User id not found in token payload #{payload}"
    end

    Rails.logger.debug("Getting user with id #{user_id} from database")
    user = Api::V1::User.find(user_id)

    unless user
      Rails.logger.error("INVALID_JWT_TOKEN: User with id #{user_id} not found")
      raise Exception "INVALID_JWT_TOKEN: User with id #{user_id} not found"
    end

    return user
  end
end