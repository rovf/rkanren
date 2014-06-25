class SessionsController < ApplicationController

  def create
    user=User.find_by_name(params[:session][:name].downcase)
    if user && user.authenticate(params[:session][:password])
      set_current_user(user)
      redirect_to dicts_url, notice: 'Welcome, '+user.name
    else
      # We need to use flash.now instead of flash, because we are doing a
      # render, not a redirect
      flash.now[:error]='Invalid user id and/or password'
      render 'new'
    end
  end

  def become_guest
    drop_current_user
    redirect_to dicts_url, notice: 'You are now logged out'
  end

  def destroy
    drop_current_user
    redirect_to root_url, notice: 'You are now logged out'
  end

end
