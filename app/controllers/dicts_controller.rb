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
    logger.debug('DictsController create: '+params.inspect)
    # Next line needs to be fixed, when we have user authentification
    dict_params.permit(:user_id,:dictname,:language)
    logger.debug('dict_params after:'+dict_params.inspect)
    @dict = Dict.new(dict_params)
    @dict.user_id=current_user_id
    logger.debug('dict object:'+@dict.inspect)
    if @dict.save
      redirect_to @dict, notice: 'New dictionary'
    else
      @dicts=Dict.all # needs to be filtered?
      render :index
    end
  end

  # PATCH/PUT /dicts/1
  # PATCH/PUT /dicts/1.json
  def update
    respond_to do |format|
      if @dict.update(dict_params)
        format.html { redirect_to @dict, notice: 'Dict was successfully updated.' }
        format.json { render :show, status: :ok, location: @dict }
      else
        format.html { render :edit }
        format.json { render json: @dict.errors, status: :unprocessable_entity }
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
      @card=choose_card_for_dict(d,params[:kind])
      logger.debug("Card choosen: "+@card.inspect)
      # redirect_to(dict_path(d.id))
      render :training_unit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dict
      @dict = Dict.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dict_params
      params.require(:dict).permit(:dictname, :user_id, :accessed, :language, :max_level_kanji, :max_level_kana, :max_level_gaigo)
    end

    def verified_dict(dictid=nil)
      @verified_dict_error=nil
      dictid||=params[:id]
      logger.debug("+++++++++ verify dict "+dictid.to_s)
      dict = Dict.find_by_id(dictid)
      if dict.nil?
        @verified_dict_error="Dictionary "+dictid.to_s+" does not exist"
      elsif dict.user_id != current_user_id
        @verified_dict_error="You have no right to access to dictionary number "+dictid.to_s
        dict=nil
      end
      logger.debug("+++++++++ verified dict:"+dict.inspect)
      dict
    end

    def with_verified_dict(dictid,fail_redirect)
      dict=verified_dict(dictid)
      if(dict.nil?)
        flash[:error]=verified_dict_error
        redirect_to fail_redirect unless fail_redirect.blank?
      else
        if block_given?
          yield dict if block_given?
        end
      end
      dict
    end

  def with_verified_dictparam(fail_redirect,&block)
    with_verified_dict(nil,fail_redirect,&block)
  end
end
