class CardsController < ApplicationController

  def new
    logger.debug('========CardsController new: '+params.inspect)
    @dict=Dict.find(params['dict_id'])
    @current_dictname=@dict.dictname
    @rep=Array.new(Rkanren::NREPS,'')
    @notes=Array.new(Rkanren::NREPS,'')
    @card=Card.new(dict_id:params['dict_id'])
    logger.debug('======= leaving CardsController.new')
  end

  # params:
  #  "card"=>{"usernote"=>"AAAAA"}, "gaigo"=>"BBBBBBB",
  #  "gaigo_notes"=>"CCCCCC", ... , "dict_id"=>"4"
  def create
    logger.debug('CardsController create: '+params.inspect)
    @dict=Dict.find(params['dict_id'])
    @current_dictname=@dict.dictname
    @rep||=[]
    Rkanren::NREPS.times do |kind|
      @rep[kind]=(params[Rkanren::KIND_TXT[kind]]||'').strip
    end
    @card=Card.new(
      dict_id:params['dict_id'],
      usernote:params['card']['usernote']||'',
      n_repres:(@rep[Rkanren::KANJI].length == 0 ? 2 : 3))
    if @card.save
      logger.debug('========New card: '+@card.inspect)
      @card.destroy # TO BE REMOVED
      @idioms=[]
      @card.n_repres.times do |kind|
        @idioms[kind]=Idiom.new(
          repres: @rep[kind],
          card_id: @card.id,
          note: params[Rkanren::KIND_REP_NOTE[kind]],
          atari: 0,
          level: 0, # TODO: Place in highest level
          kind: kind)
        logger.debug('========== New Idiom: '+@idiom.inspect)
        # TODO: Save and error recovery (REMOVE DESTROY ABOVE)
      end
    else
      logger.debug("can not save Card object")
      render('new')
    end
  end

  def destroy
  end

  def edit
  end
end
