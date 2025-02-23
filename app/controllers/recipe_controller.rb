class RecipeController < ApplicationController
  before_action :set_recipe, only: [ :show, :update, :destroy ]
  def index
    recipes = Recipe.all
    render json: recipes
  end


  def show
    render json: @recipe
  end


  def create
    recipe_params = params.require(:recipe).permit(:name, :rating, :image, :portions, :userId, :description, :time, :instruction, :ingredients)
    recipe_params[:image] = params[:file_url] if params[:file_url].present?
    recipe_params[:rating] = params[:rating].to_i if params[:rating].present?
    recipe_params[:userId] = params[:userId].to_i if params[:userId].present?

    validation_result = validate_recipe_to_create(recipe_params)


    unless validation_result[:success]
      return render json: {
        error: "Dados inválidos.",
        fields: validation_result[:errors]
      }, status: :bad_request
    end

    recipe = Recipe.new(recipe_params)


    if recipe.save
      render json: {
        success: "Receita #{recipe.id} criada com sucesso.",
        recipe: recipe
      }
    else
      render json: {
        error: "Erro ao cadastrar receita.",
        fields: recipe.errors.full_messages
      }, status: :unprocessable_entity
    end


    def update
      recipe_params = params.require(:recipe).permit(:name, :rating, :image, :portions, :userId, :description, :time, :instruction, :ingredients)

      recipe_params[:image] = params[:file_url] if params[:file_url].present?

      if @recipe.update(recipe_params)
       render json: { success: "Receita #{@recipe.id} editada com sucesso.", recipe: @recipe }
      else
        render json: { error: "Erro ao atualizar a receita.", fields: @recipe.errors.full_messages }, status: :unprocessable_entity
      end

    rescue => e
      Rails.logger.error e.message
      render json: { error: "Ops, erro no servidor." }, status: :internal_server_error
    end

    def destroy
      if @recipe.destroy
        render json: { success: "Receita #{@recipe.id} removida com sucesso." }
      else
        render json: { error: "Erro ao excluir a receita." }, status: :unprocessable_entity
      end
    end

    private

    def set_recipe
      @recipe = Recipe.find_by(id: params[:id])
      render json: { error: "Receita não encontrada" }, status: :not_found unless @recipe
    end

    def validate_recipe_to_create(recipe_params)
      schema = RecipeSchema.new
      result = schema.call(recipe_params)

      result.success? ? true : result.errors.to_h
    end
  end
end
