class CardsController < ApplicationController

  def new
    logger.debug('========CardsController new: '+params.inspect)
    @dict=Dict.find(params['dict_id'])
    @current_dictname=@dict.dictname
    @rep=Array.new(Rkanren::NREPS,'')
    @notes=Array.new(Rkanren::NREPS,'')
    @card=Card.new(dict_id:params['dict_id'])
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
      @idioms=[]
      @card.n_repres.times do |kind|
        @idioms[kind]=Idiom.new(
          repres: @rep[kind],
          card_id: @card.id,
          note: params[Rkanren::KIND_REP_NOTE[kind]],
          atari: 0,
          level: 1, # TODO: Place in highest level
          kind: kind)
        unless @idioms[kind].save
          logger.debug("Can not save "+Rkanren::KIND_TXT[kind]+"-Idiom object")
          @card.destroy
          break
        end
      end
    else
      logger.debug("can not save Card object")
      render('new')
    end
  end

  def index
    logger.debug("CardsController.index "+params.inspect)
    # Todo: If the dictionary is large, show only the first
    # page and provide a paging function
    # Note: Instead of card_ids, we can also write pluck(:card_id)
    # Starting with Rails 4, pluck can even be used to select more
    # than one column.
    @idiom_index_list=(@dict||Dict.find(params[:dict_id])).card_ids.map do |cid|
      # find raises exception, if Object has been deleted in
      # between. find_by_.... returns nil in this case.
      card=Card.find_by_id(cid)
      result=nil
      if not card.nil?
        # 'where' returns array
        iarr=Idiom.where(card_id: cid, kind: Rkanren::GAIGO)
        if iarr.length > 0
          result={:card_id => cid, :gaigo => iarr[0].repres}
        end
      end
      result
    end.select { |i| not i.nil? }
    # TODO: We should redirect to the dictionary page instead
    flash.now[:notice]='Dictionary is empty' if @idiom_index_list.length==0
    logger.debug("index list:\n"+@idiom_index_list.inspect)
  end

  def destroy
  end

  def edit
  end
end
