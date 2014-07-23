class IdiomsController < ApplicationController

  before_action :check_permission

  # params["judgement"] : "accept" or "reject"
  # @idiom and @dict set by before_action
  def update_score
    accepted = { 'accept' => true, 'reject' => false}[params[:judgement]] or raise Exception.new("Unexpected :judgement parameter")

    # set timestamp in idiom to indicate that it was asked now (we should
    # maybe better do this when presenting the idiom?

    # change the 'atari' by accepted:1 rejected:-1
    # if abs(atari) becomes too large(small), set atari to 0 and change
    # the level by -1/+1, with the following pecularities:
    # The level can not go below MINLEVEL (0?)
    # If the number of word in the current level becomes 0, consolidate
    # the levels.
    # Update the max_level attribute, if necessary

    # TODO: Prepare next idiom
    redirect_to renshuu_path(@dict,@idiom.kind)
  end

  def edit
  end

  def update
  end

private

  def check_permission
    @idiom = Idiom.find_by_id(params[:id])
    @dict = @idiom.card.dict
    user_for_idiom = @dict.user
    if current_user_id != user_for_idiom.id
      logger.debug("SECURITY ALERT IdiomsController: Current User = ",
          current_user_name, ", Idiom #{@idiom.id} Owner = ",
          user_for_idiom.name)
      flash[:error]="No permission to modify other user's idioms"
      redirect_to root_path
    end
  end

end
