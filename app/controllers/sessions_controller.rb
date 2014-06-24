class SessionsController < ApplicationController

  def create
    user=User.find_by_name(params[:session][:name].downcase)
    if user && user.authenticate(params[:session][:password])
      flash.now('Signin not implemented yet')
    else
      # We need to use flash.now instead of flash, because we are doing a
      # render, not a redirect
      flash.now[:error]='Invalid user id and/or password'
      render 'new'
    end
  end

  def destroy

  end

end
