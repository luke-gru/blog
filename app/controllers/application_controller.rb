# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_locale

  def current_admin_user
    user = current_user
    return if user.nil?
    return user if user.admin?
  end

  protected

  def set_locale
    I18n.locale = params[:locale]
    unless I18n.available_locales.include?(I18n.locale)
      I18n.locale = I18n.default_locale
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }
  end
end
