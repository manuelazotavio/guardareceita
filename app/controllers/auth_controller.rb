class AuthController < ApplicationController
  require "jwt"

  SECRET_KEY = Rails.application.secrets.secret_key_base

  def login
    email = params[:email]
    password = params[:pass]


    user = User.find_by(email: email)

    if user.nil? || !user.authenticate(password)

      render json: { error: "Email ou senha inválida.", status: :unauthorized }

    end

    token = JWT.encode({ id: user.id, name: user.name, exp: 24.hours.from_now.to_i }, SECRET_KEY, "HS256")

    Session.create!(user_id: user.id, token: token)

    render json: {
      message: "Usuário logado",
      token: token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        avatar: user.avatar
      }
    }

  rescue => e
    Rails.logger.error e.message
    render json: { error: "Ops, erro no servidor." }, status: :internal_server_error
  end
end
