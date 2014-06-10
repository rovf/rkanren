class DictsController < ApplicationController
  before_action :set_dict, only: [:show, :edit, :update, :destroy]

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
    @dicts = Dict.all
    if @filter.length > 0
      re=params['filtertype'] == 'regexp' ? @filter : '\\A'+Regexp::escape(@filter)
      logger.debug('Filtering according to '+re.to_s)
      @dicts=@dicts.select { |d| d.dictname.match(re) }
    end
    logger.debug('Number of :dict objects selected: '+@dicts.length.to_s)
    @dicts=@dicts.sort {|d1,d2| d1.dictname <=> d2.dictname }
  end

  # GET /dicts/1
  # GET /dicts/1.json
  def show
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
    dict_params[:user_id]=User.guestid
    logger.debug('dict_params after:'+dict_params.inspect)
    @dict = Dict.new(dict_params)
    @dict.user_id=User.guestid
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dict
      @dict = Dict.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dict_params
      params.require(:dict).permit(:dictname, :user_id, :accessed, :language, :max_level_kanji, :max_level_kana, :max_level_gaigo)
    end
end
