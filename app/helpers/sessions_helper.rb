module SessionsHelper

  def set_current_user(user)
    if session[:currentUser].nil? or user.name != session[:currentUser]
      set_no_training
      session[:currentUserId]=nil # will be recalculated if needed
      session[:currentUser]=user.name
    end
  end

  def set_new_name_for_current_user(new_name)
    session[:currentUser]=new_name
  end

  def drop_current_user
    session[:currentUser]=nil
    session[:currentUserId]=User.guestid
    set_no_training
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

  def current_user
    current_user_is_guest? ? User.guest : User.find_by_id(current_user_id)
  end

  def current_user_is_guest?
    current_user_name == User.guestname
  end

  def current_userid_is_guest?
    current_user_id == User.guestid
  end

  # Passing nil means no training going on
  def set_current_kind(kind)
    session[:kind]=kind
  end

  def set_no_training
    set_current_kind(nil)
  end

  def current_kind
    session[:kind]
  end

end
