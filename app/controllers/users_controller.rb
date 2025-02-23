class UsersController < ApplicationController
    require "bcrypt"

    before_action :set_user, only: [ :show, :update, :destroy ]
    before_action :authorize_user, only: [ :update ]

    def index
            users = User.all
            render json: users
    end

    def show
            render json: @user
    end

    def create
      user_params = params.require(:user).permit(:name, :email, :password, :avatar)

      validation_result = validate_user_to_create(user_params)

      unless validation_result[:success]
        return render json: {
          error: "Dados de cadastro inválidos",
          fields: validation_result[:errors]
        }, status: :bad_request
      end

      user_params[:password] = BCrypt::Password.create(user_params[:password])
      user_params[:avatar] = params[:file_url] if params[:file_url].present?

      user = User.new(user_params)

      if user.save
        render json: {
          success: "Usuário #{user.id} criado com sucesso.",
          user: user
        }
      else
        render json: {
          error: "Erro ao criar usuário",
          fields: user.errors.full_messages
        }, status: :unprocessable_entity
      end

    rescue ActiveRecord::RecordNotUnique
      render json: {
        error: "O email informado já está cadastrado.",
        fields: { email: "Este e-mail já está em uso" }
      }, status: :bad_request
    end


    def update
        user_params = params.require(:user).permit(:name, :email, :avatar)

        user_params[:avatar] = params[:file_url] if params[:file_url].present?

        if @user.update(user_params)
                    render json: { success: "Usuário #{@user.id} editado com sucesso.", user: @user }
        else
            render json: { error: "Erro ao atualizar o usuário.", fields: @user.errors.full_messages }, status: :unprocessable_entity
        end
    rescue => e
        Rails.logger.error e.message
        render json: { error: "Ops, erro no servidor." }, status: :internal_server_error
    end

    private

    def set_user
            @user = User.find_by(id: params[:id])
            render json: { error: "Usuário não encontrado" }, status: :not_found unless @user
    end

    def validate_user_to_create(user_params)
      errors = {}

      errors[:email] = "E-mail é obrigatório" if user_params[:email].blank?
      errors[:password] = "Senha deve ter pelo menos 6 caracteres" if user_params[:password].to_s.length < 6

      { success: errors.empty?, errors: errors }
    end

    def authorize_user
        return if @user.id == current_user.id
            render json: { error: "Não autorizado a atualizar outro usuário." }, status: :unauthorized
    end
end
