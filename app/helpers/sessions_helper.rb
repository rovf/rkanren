module SessionsHelper

  def set_current_user(user)
    session[:currentUserId]=nil # will be recalculated if needed
    session[:currentUser]=user.name
  end

  def drop_current_user
    session[:currentUser]=nil
    session[:currentUserId]=User.guestid
  end

  def current_user_name
    session[:currentUser] || User.guestname
  end

  def current_user_id
    if session[:currentUserId].nil?
      cu=current_user_is_guest? ? User.guest : User.find_by_name(current_user_name)
      if cu.nil?
        flash.now('Unknown user!')
        drop_current_user # sets :currentUserId in session
      else
        session[:currentUserId]=cu.id
      end
    end
    session[:currentUserId]
  end

  def current_user_is_guest?
    current_user_name == User.guestname
  end

  def current_userid_is_guest?
    current_user_id == User.guestid
  end

end
