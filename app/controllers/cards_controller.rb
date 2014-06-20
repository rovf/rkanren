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
    @dict=Dict.find(params['dict_id'])
    @current_dictname=@dict.dictname
    if params.has_key?('cancel')
      redirect_to dict_path(@dict.id)
    else
      @rep||=stripped_reps
      @card=Card.new(
        dict_id:params['dict_id'],
        usernote:params['card']['usernote']||'',
        n_repres:(@rep[Rkanren::KANJI].length == 0 ? 2 : 3))
      @idioms=[]
      @notes=idiom_notes # for redisplaying in case of error
      @card.n_repres.times do |kind|
        @idioms[kind]=Idiom.new(
          repres: @rep[kind],
          card_id: @card.id,
          note: @notes[kind],
          atari: 0,
          level: 1, # TODO: Place in highest level
          kind: kind)
      end
      unless @card.save_with_idioms(@idioms)
        logger.debug("Can not save object")
        render('new')
      end
    end
  end

  def update
    @card=Card.find(params[:id])
    @dict=Dict.find(@card.dict_id)
    if params.has_key?('cancel')
      redirect_to dict_cards_path(@dict.id)
    else
      # TODO: Find a more sensible initial level for a new
      #       Kanji representation.
      # TODO: Error messages during saving are not passed
      #       to the user, because update_user_data uses
      #       local idiom objects.
      if @card.update_user_data(params['card']['usernote'], stripped_reps, idiom_notes, 1)
        redirect_to dict_card_path(@dict,@card)
      else
        logger.debug("Can not update object")
        render 'edit'
      end
    end
  end

  def index
    # Todo: If the dictionary is large, show only the first
    # page and provide a paging function
    # Note: Instead of card_ids, we can also write pluck(:card_id)
    # Starting with Rails 4, pluck can even be used to select more
    # than one column.
    @dict||=Dict.find(params[:dict_id])
    @idiom_index_list=@dict.card_ids.map do |cid|
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
    if @idiom_index_list.length==0
      flash[:notice]='The Dictionary is empty'
      redirect_to dict_url(@dict.id)
    else
      logger.debug("index list:\n"+@idiom_index_list.inspect)
    end
  end

  def destroy
  end

  def show
    @card=Card.find(params[:id])
    @idioms=@card.idioms # .order('kind ASC') .... now done implicitly in model
    logger.debug("CardsController show (sorted?):"+@idioms.inspect)
    @dict=Dict.find(@card.dict_id) # Needed for form_for [...]
  end

  def edit
    @card=Card.find(params[:id])
    @dict=Dict.find(@card.dict_id) # Needed for form_for [...]
    if params.has_key?('cancel')
      redirect_to dict_path(@dict.id)
    else
      @idioms=@card.idioms
      @rep=@idioms.map {|i| i.repres }
      @notes=@idioms.map {|i| i.note }
    end
  end

private

  # Retrieves in params the representations in the three
  # kinds, and returns an array of the stripped values.
  def stripped_reps
    @rep||=[]
    Rkanren::NREPS.times do |kind|
      @rep[kind]=(params[Rkanren::KIND_TXT[kind]]||'').strip
    end
    @rep
  end

  # Retrieves in params the notes for the idioms (not the
  # usernote for the whole card) and returns them as an array
  def idiom_notes
    @notes=[] # for redisplaying in case of error
    Rkanren::NREPS.times do |kind|
      @notes[kind]=params[Rkanren::KIND_REP_NOTE[kind]]
    end
    @notes
  end

end
