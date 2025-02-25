class AuthController < ApplicationController
  require "jwt"

  before_action :set_token, only: [ :login, :logout ]


  TOKEN_EXPIRES_IN = 24.hours
  DB_TOKEN_EXPIRES_DAYS = 1.day
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


    cookies[:token] = {
      value: token,
      httponly: true,
      same_site: :none
    }
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
  end

  def refresh_token
    session = Session.find_by(token: token)

      if session.nil?
        cookies.delete(:token, httponly: true, same_site: :none, secure: true)
        render json: { error: "Sessão não encontrada, faça login novamente!", code: "logout" }, status: :unauthorized
      end

      new_token = JWT.encode({ id: current_user.id, name: current_user.name, exp: TOKEN_EXPIRES_IN.from_now.to_i }, SECRET_KEY, "HS256")

      cookies[:token] = {
        value: new_token,
        httponly: true,
        same_site: :none,
        secure: true,
        expires: 24.hours.from_now
      }

      session.update(token: new_token, created_at: Time.now)

      render json: {
        message: "Token atualizado com sucesso!",
        new_token: new_token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          avatar: user.avatar
        }
      }
  rescue JWT::DecodeError
      render json: { error: "Token inválido.", code: "logout" }, status: :unauthorized
  rescue => e
      Rails.logger.error e.message
      render json: { error: "Ops, erro no servidor, tente novamente!" }, status: :internal_server_error
  end



  def logout
        user = current_user
        return render json: { error: "Usuário não autenticado." }, status: :unauthorized unless user

        Session.where(user_id: current_user.id, token: request.headers["Authorization"]).destroy_all

        cookies.delete(:token, httponly: true, same_site: :none)

        render json: { message: "Logout realizado com sucesso!" }, status: :ok

  rescue => e
        Rails.logger.error e.message
        render json: { error: "Ops, erro no servidor." }, status: :internal_server_error
  end

    private

    def current_user
      decoded_token = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256").first
        User.find_by(id: decoded_token["id"])
    rescue JWT::DecodeError
          nil
    end

    def set_token
      token = request.headers["Authorization"]&.split("Bearer ")&.last
      nil unless token
      render json: { error: "Token não encontrado." }, status: :unauthorized unless token
    end
end
