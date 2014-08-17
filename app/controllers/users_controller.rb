 class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  # This is used for changing the password
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.name =~ /^[\w\d][^<>]/
      respond_to do |format|
        if @user.save
          drop_current_user
          # TODO: Automatically sign in here
          format.html { redirect_to new_session_path, notice: 'User was successfully created. You can now login with your username.' }
        else
          format.html { render :new }
        end
      end
    else
      flash.now[:error]="User names must start with a letter, underscore or digit, and must not contain angle brackets"
      render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    new_values=user_params # .to_hash.symbolize_keys! # can't do the strip! otherwise
    logger.debug('+++++++ new_values='+new_values.to_hash.inspect)
    [:name,:email].each {|f| new_values[f].striP!.downcase!}
    new_values.delete(:name) if new_values[:name].length==0
    if no_password?(new_values)
      [:password,:password_confirmation].each {|f| new_values.delete(f)}
    end
    logger.debug('++++++++ new_values after: '+new_values.inspect)
    if @user.update_attributes(new_values)
      logger.debug('+++++++++++++ SUCCESS')
      set_new_name_for_current_user(@user.name) # In case of name change
      flash.now[:success]="Change(s) are applied"
    end
    render 'edit'
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
      if @user.id != current_user_id
        redirect_to root_path, notice: "You tried to fiddle with another users profile. You are bad, very bad!"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email,:password,:password_confirmation)
    end

    def no_password?(pars)
      pars[:password].length + pars[:password_confirmation].length == 0
    end
end
