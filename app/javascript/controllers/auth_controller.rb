
class AuthController < ApplicationController
    def login
      begin

        # pegando as coisa da requisicao

        email = params[:email]
        pass = params[:pass]


        if result[:success] == false
          return render json: { error: "Dados de atualização inválidos", fields: result[:error] }, status: :bad_request
        end

        user_found = User.find_by(email: email)

        unless user_found
          return render json: { error: "Email ou senha inválida" }, status: :unauthorized
        end

        pass_is_valid = BCrypt::Password.new(user_found.pass) == pass

        unless pass_is_valid
          return render json: { error: "Email ou senha inválida" }, status: :unauthorized
        end

        token = generate_jwt(user_found)

        cookies.signed[:token] = { value: token, httponly: true, secure: Rails.env.production?, same_site: "None", expires: 1.day.from_now }

        date = Time.now.utc - 3.hours

        Session.create(user_id: user_found.id, token: token, created_at: date)

        render json: {
          message: "User Logado!",
          token: token,
          user: {
            id: user_found.id,
            name: user_found.name,
            email: user_found.email,
            avatar: user_found.avatar
          }
        }

      rescue => e
        Rails.logger.error(e)
        render json: { error: "Opsss erro no servidor, tente novamente!" }, status: :internal_server_error
      end
    end

    private

    def validate_user_to_login(email, pass)
      # Implementar validação semelhante ao Zod ou usar outra gem
      { success: true } # Este é um exemplo simples
    end

    def zod_error_format(error)
      # Converter erro para o formato esperado
      { message: error.message } # Exemplo simples
    end

    def generate_jwt(user)
      payload = { id: user.id, name: user.name }
      JWT.encode(payload, ENV["SECRET_KEY"], "HS256", exp: 24.hours.from_now.to_i)
    end
end
