# OBSOLETE????

class HomeController < ApplicationController
  def init
    logger.debug("HomeController.init")
    reset_message
  end

  # params hash:
  #   username
  #   dictionaryname
  #   dictionarykind
  #   create / open
  def login
    logger.debug(params.inspect)
    reset_message
    username=params[:username].strip
    dictionaryname=params[:dictionaryname].strip
    dictionarykind=params[:dictionarykind].strip
    logger.debug("#{username}/#{dictionaryname}/#{dictionarykind}")
    # Once we have user registration and password
    # authentification, this should be done here.
    if username.empty?
      set_message('User ID missing')
    elsif dictionarykind.empty?
      set_message('Dictionary language missing')
    elsif params.has_key?('create')
      redirect_to url_for(:controller => :dicts, :action => :new)
      # redirect_to url_for(:controller => :dicts, :action => :create, :method => :post)
    elsif params.has_key?('open')
      if dictionaryname.empty?
        set_message('not implemented yet')
        action='open'
      else
        set_message('not implemented yet')
        action='pick'
      end
    else
      set_message('Unexpected submit key')
    end
    if has_message?
      logger.debug(message)
      render 'init'
    end
  end

private

  def reset_message
    set_message('')
  end

  def set_message(_m)
    logger.debug('setting message to: '+_m.inspect)
    @message=_m
  end

  def has_message?
    not @message.empty?
  end

  def message
    @message
  end

end
