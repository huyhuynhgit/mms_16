class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :require_admin

  def require_admin
    redirect_to root_path unless current_user.admin?
  end
end
