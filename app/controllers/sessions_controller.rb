class SessionsController < ApplicationController

  # params contain a key LOGIN if it is a normal login, or FORGOT_PWD if it is a
  # request to recover the password
  def create
    user=User.find_by_name(params[:session][:name].downcase)
    if user
      if params.has_key?('FORGOT_PWD')
        forgot_password(user)
      elsif user.authenticate(params[:session][:password])
        set_current_user(user)
        redirect_to dicts_url, notice: 'Welcome, '+user.name
      else
        # We need to use flash.now instead of flash, because we are doing a
        # render, not a redirect
        flash.now[:error]='Invalid password'
        render 'new'
      end
    else
      flash.now[:error]='This user does not exist'
      render 'new'
    end
  end

  def forgot_password(user)
    mailaddr=user.email
    if mailaddr.blank?
      logger.debug('No mail address available')
      flash[:error]='No email address stored for user '+user.name
      redirect_to root_path
    elsif mailaddr =~ /@(.+)[.]\w+$/
      mail_domain=$1
      newpwd=user.new_random_password!
      send_mail(mailaddr,'rkanren password reset',"New password:\n#{newpwd}")
      flash.now[:success]="An email with the new password has been sent to your #{mail_domain} account"
      render 'new'
    else
      flash[:error]='No email sent, because mail address is invalid: "'+mailaddr+'"'
      redirect_to root_path
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
