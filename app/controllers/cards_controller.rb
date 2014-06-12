class CardsController < ApplicationController
  # params: dict_id
  def new
    logger.debug('CardsController new: '+params.inspect)
    @dict=Dict.find(params['dict_id'])
    @current_dictname=@dict.dictname
    @card=Card.new(dict_id:params['dict_id'])
  end

  def create
    logger.debug('CardsController new: '+params.inspect)
  end

  def destroy
  end

  def edit
  end
end
