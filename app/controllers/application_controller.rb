class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  include TheRoleController

  protect_from_forgery with: :exception

  # your Access Denied processor
  def access_denied
    return render(text: 'access_denied: requires a role')
  end

  # 1) LOGIN_REQUIRE => authenticate_user!    for Devise
  # 2) LOGIN_REQUIRE => require_login         for Sorcery
  # 3) LOGIN_REQUIRE => user_require_method   for other Authentication solution

  # Define method aliases for the correct TheRole's controller work
  alias_method :login_required,     :authenticate_user!
  # alias_method :role_access_denied, :access_denied
end
