class IdiomsController < ApplicationController

  before_action :check_permission

  # params["judgement"] : "accept" or "reject"
  # @idiom and @dict set by before_action
  def update_score
    kind=@idiom.kind
    accepted = { 'accept' => true, 'reject' => false}[params['judgement']]
    raise Exception.new("Unexpected :judgement parameter") if accepted.nil?
    accepted_boost=accepted ? 1 : -1

    # queried_time is already set before querying (otherwise, SKIP)
    # would not work.

    # save old values for user feedback
    old_atari=@idiom.atari
    old_level=@idiom.level
    new_level=old_level # default

    # change the 'atari' by accepted:1 rejected:-1
    new_atari=old_atari+accepted_boost

    # if abs(atari) becomes too large(small), set atari to 0 and change
    # the level by -1/+1, with the pecularities listed below:
    if new_atari.abs >= Rkanren::MAX_ATARI
      new_atari=0
      # The level can not go below MINLEVEL
      new_level=[old_level-accepted_boost,Rkanren::MIN_LEVEL].max
      # If the number of word in the current level becomes 0,
      # consolidate the levels, unless we are already on the top
      # level
      if old_level != new_level
        # Get number of entries at old_level for this kind. If this is
        # 1, this level will become empty and we need to consolidate
        # levels. Exception: If we are already on the highest level.
        n_old_level=@idiom.count_same_kind_and_level(@dict)
        logger.debug("entries at level #{old_level} : #{n_old_level}")
        old_max_level = @dict.max_level(kind)
        if n_old_level <= 1 and new_level > old_max_level
          # No level change necessary
          new_level=old_level
        else
          if new_level > old_max_level
            # Increase max level
            @dict.update_max_level(kind,new_level)
          end
          # Move idiom to new level
          @idiom.update_attributes!(level: new_level)
          # If necessary, consolidate levels
          # TODO
          consolidate_levels(old_level) if n_old_level <= 1
        end # if else Level change verified
      end # if Level change requested


    end # if atari exceeds maximum value

    # Update the max_level attribute, if necessary

    # TODO: Prepare next idiom
    redirect_to renshuu_path(@dict,kind)
  end # update_score

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

  def consolidate_levels(empty_level)
    # From idioms in empty_level+ 1 to max level: decrease levels
    # in all idioms
  end

end
