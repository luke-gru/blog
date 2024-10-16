class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_admin_user
    user = current_user
    return if user.nil?
    return user if user.admin?
  end
end
