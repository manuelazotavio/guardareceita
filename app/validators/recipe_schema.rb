require "dry-validation"

class RecipeSchema < Dry::Validation::Contract
  params do
    optional(:id).filled
    required(:userId).filled(:string)
    required(:image).filled(:string)
    required(:name).filled(:string, min_size?: 3, max_size?: 200)
    required(:rating).filled
    required(:portions).filled(:string, min_size?: 3, max_size?: 30).or(filled(:integer, gteq?: 3, lteq?: 30))
    required(:description).filled(:string, min_size?: 3, max_size?: 200)
    required(:time).filled(:string, min_size?: 1, max_size?: 30).or(filled(:integer, gteq?: 1, lteq?: 30))
    required(:instruction).filled(:string, min_size?: 3, max_size?: 400).or(filled(:integer, gteq?: 3, lteq?: 400))
    required(:ingredients).filled(:string, min_size?: 3, max_size?: 400) | filled(:integer, gteq?: 3, lteq?: 400)
  end
end
