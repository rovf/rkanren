module SessionsHelper

  def set_current_user(user)
    session[:currentUser]=user.name
  end

  def drop_current_user
    session[:currentUser]=nil
    session[:currentUserId]=nil
  end

  def current_user_name
    session[:currentUser] || User.guestname
  end

  def current_user_id
    if session[:currentUserId].nil?
      cu=current_user_is_guest? ? User.guest : User.find_by_name(current_user_name)
      if cu.nil?
        flash.now('Unknown user!')
        session[:currentUserId]=0
        drop_current_user
      else
        session[:currentUserId]=cu.id
      end
    end
    session[:currentUserId]
  end

  def current_user_is_guest?
    current_user_name == User.guestname
  end

end
