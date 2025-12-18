class ApplicationController < ActionController::Base
  before_action :set_tenant
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_account
  private

  def set_tenant
    if request.subdomain.present? && request.subdomain != 'www'
      account = Account.find_by(subdomain: request.subdomain, active: true)

      if account
        ActsAsTenant.current_tenant = account
        @current_account = account
      else
        redirect_to_main_site
      end
    else
      # Main site - no tenant
      ActsAsTenant.current_tenant = nil
      @current_account = nil
    end
  end

  def redirect_to_main_site
    redirect_to root_url(subdomain: false)
  end

  def current_account
    @current_account
  end

  def require_super_admin!
    unless current_user&.super_admin?
      redirect_to root_path, alert: 'Access denied. Super admin only.'
    end
  end

  def require_venue_staff!
    unless current_user&.venue_staff?
      redirect_to root_path, alert: 'Access denied. Staff only.'
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :player_type, :skill_level])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :player_type, :skill_level])
  end

  def after_sign_in_path_for(resource)
    if resource.super_admin?
      super_admin_root_path
    elsif resource.venue_staff?
      admin_root_path
    else
      root_path
    end
  end
end
