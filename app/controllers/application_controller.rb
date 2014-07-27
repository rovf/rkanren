class ApplicationController < ActionController::Base

  # Prevent CSRF (cross site request forgery) attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Helpers are by default visible in views, but not in controllers
  include ApplicationHelper
  include SessionsHelper
  include DictsHelper

end
