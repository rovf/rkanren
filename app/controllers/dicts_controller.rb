require 'will_paginate/array'

class DictsController < ApplicationController

  include ActionView::Helpers::TextHelper

  before_action :set_dict, only: [:show, :edit, :update, :destroy]

  attr_reader :verified_dict_error

  # GET /dicts
  # GET /dicts.json
  # If called from within index.html.erb page, params will
  # contain something like:
  # "filter"=>"xxxxxxxxx", "filtertype"=>"regexp"
  # Depending on the button clicked, apply_filter or clear_filter
  # will be present.
  def index
    @dict ||= Dict.new # clears error list
    logger.debug('DictsController index: '+params.inspect)
    if params.has_key?('clear_filter')
      @filter=''
    elsif params.has_key?('apply_filter')
      @filter=params['filter'].strip
    else
      @filter ||= ''
    end
    @user=User.find_by_id(current_user_id)
    @dicts = @user.dicts
    logger.debug(pluralize(@dicts.length,'dictionary')+' [yet unfiltered] found for user '+current_user_id.to_s+' ('+current_user_name+')')
    if @filter.length > 0
      re=params['filtertype'] == 'regexp' ? @filter : '\\A'+Regexp::escape(@filter)
      logger.debug('Filtering according to '+re.to_s)
      @dicts=@dicts.select { |d| d.dictname.match(re) }
    end
    logger.debug('Number of :dict objects selected: '+@dicts.length.to_s)
    @dicts=@dicts.sort {|d1,d2| d1.dictname <=> d2.dictname }
  end

  # GET /dicts/1
  def show
    with_verified_dictparam(dicts_path) do |d|
      @dict=d # In case we need it in view
      @n_cards=n_cards_in_dict(d)
      logger.debug("DictsController.show : setting n_cards "+@n_cards.inspect)
      @has_kanji_entries_p=has_kanji_entry?(d)
    end
  end

  # GET /dicts/new
  def new
    logger.debug('DictsController new: '+params.inspect)
    @dict = Dict.new
  end

  # GET /dicts/1/edit
  def edit
  end

  # POST /dicts
  def create
    dict_params.permit(:dictname,:language,:world_readable)
    logger.debug('dict_params after:'+dict_params.inspect)
    @dict = Dict.new(dict_params)
    @dict.user_id=current_user_id
    logger.debug('dict object:'+@dict.inspect)
    @dicts=Dict.all # needs to be filtered?
    if @dict.dictname[0,1] == Dict::SIGIL_INTERNAL_DICT
      flash.now[:error]="Dictionary name must not start with "+Dict::SIGIL_INTERNAL_DICT
      render :index
    elsif @dict.save
      redirect_to @dict, notice: 'New dictionary'
    else
      render :index
    end
  end

  # PATCH/PUT /dicts/1
  def update
    if params[:dict][:dictname][0,1] == Dict::SIGIL_INTERNAL_DICT
      flash.now[:error]="Dictionary names starting with  "+Dict::SIGIL_INTERNAL_DICT+" are for internal use only"
      render :edit
    else
      respond_to do |format|
        if @dict.update(dict_params)
          format.html { redirect_to @dict, notice: 'Dict was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /dicts/1
  # DELETE /dicts/1.json
  def destroy
    @dict.destroy
    respond_to do |format|
      format.html { redirect_to dicts_url, notice: 'Dict was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # params: id (of dict)
  #         kind
  def start_training
    with_verified_dictparam(dicts_path) do |d|
      @dict=d # In case we need it in view
      kind=params[:kind].to_i
      @card=choose_card_for_dict(d,kind)
      if kind<0 or kind>=Rkanren::NREPS
        flash[:error]="Illegal 'kind':"+params[:kind]
        redirect_to(root_path)
      end
      if @card.nil?
        flash[:error]="Could not choose an idiom"
        redirect_to(dict_path(d.id))
      end
      set_current_kind(kind)
      logger.debug("Card choosen: "+@card.inspect)
      # Model guarantees that idioms are sorted according to kind
      @idioms=@card.idioms.all
      @idioms[kind].update_attributes!(queried_time: DateTime.now)
      logger.debug("+++++++ queried_time for idiom #{@idioms[kind].repres} set to #{tsshow(@idioms[kind].queried_time)}")
      @idiom_sequence=([kind]+Rkanren::QUERYSEQ[kind])[0,@idioms.length]
      render :training_unit
    end
  end

  # User requested importing a different dictionary to the current one
  def select_for_import
    # select_for_import is defined inside resource nesting. The
    # id of the dictionary is not passed in :id, as usual, but
    # in :dict_id
    with_verified_dict(params[:dict_id],root_path) do |d|
      @dict=d
      # Get all dictionary for this user. We can use the user from
      # the session, or the one recorded in d. Because of the
      # verification, they must be the same. Do not include d.
      @dicts = (the_other_dicts_of_same_user(d) +
        # Add public dictionaries from the other users
        public_dicts_of_other_users(d)).
        # Sort the list
        sort { |d1,d2| d1.dictname <=> d2.dictname } .
        # Prepare for pagination
        paginate(:page => params[:page], :per_page => 12)
      render # select_for_import
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_dict
      @dict = Dict.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dict_params
      params.require(:dict).permit(:dictname, :user_id, :accessed, :language, :max_level_kanji, :max_level_kana, :max_level_gaigo, :world_readable)
    end

end
