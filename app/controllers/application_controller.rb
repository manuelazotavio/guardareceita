class ApplicationController < ActionController::API
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # 
  skip_before_action :verify_authenticity_token
  allow_browser versions: :modern
end
