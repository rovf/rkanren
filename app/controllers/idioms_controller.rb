class IdiomsController < ApplicationController

  before_action :check_permission
  before_action :fix_idiom_data, only: :update_score

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
    old_max_level = new_max_level='?'

    # change the 'atari' by accepted:1 rejected:-1
    new_atari=old_atari+accepted_boost

    # if abs(atari) becomes too large(small), set atari to 0 and change
    # the level by -1/+1, with the pecularities listed below:
    if new_atari.abs >= Rkanren::MAX_ATARI
      # The level can not go below MINLEVEL
      new_level=[old_level-accepted_boost,Rkanren::MIN_LEVEL].max
      # If the number of word in the current level becomes 0,
      # consolidate the levels, unless we are already on the top
      # level
      if old_level != new_level
        new_atari=0 # Atari reset only if logical level change
        # Get number of entries at old_level for this kind. If this is
        # 1, this level will become empty and we need to consolidate
        # levels. Exception: If we are already on the highest level.
        n_old_level=@idiom.count_same_kind_and_level(@dict)
        logger.debug("entries at level #{old_level} : #{n_old_level}")
        new_max_level = old_max_level = @dict.max_level(kind)
        if n_old_level <= 1 and new_level > old_max_level
          # No level change necessary, because we are already in the
          # top level, and there is only one word in this level.
          new_level=old_level
          new_atari=-Rkanren::MAX_ATARI
        else
          if new_level > old_max_level
            # Increase max level
            new_max_level=new_level
            @dict.update_max_level!(kind,new_max_level)
          end
          # Move idiom to new level
          @idiom.update_attributes!(level: new_level)
          if n_old_level <= 1
            # consolidate levels
            new_max_level=consolidate_levels(kind,old_level,new_max_level)
          end
        end # if else Level change verified
      else
        # We must be at minimum level
        new_atari=Rkanren::MAX_ATARI
      end # if Level change requested
    end # if atari exceeds maximum value
    @idiom.update_attributes!(atari: new_atari)
    prepare_score_info(old_level,new_level,old_max_level,new_max_level)
    logger.debug("(update_score) scored: #{old_level}/#{new_level}/#{old_atari}/#{new_atari}/#{old_max_level}/#{new_max_level}")
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

  def fix_idiom_data
    @idiom.update_attributes!(level: Rkanren::MIN_LEVEL) if @idiom.level < Rkanren::MIN_LEVEL
  end

  # Parameter:
  #   kind : Idiom kind which is affected
  #   empty_level : The level which becomes empty
  #   max_level : The maximum level for this idiom
  # Member variables:
  #   @dict  : The idioms of this dictionary object are affected
  # Returns: The new maximum level (after consolidation)
  def consolidate_levels(kind,empty_level,max_level)
    # From idioms in empty_level+1 to max level: decrease levels
    # in all idioms
    if empty_level != max_level
      logger.debug("consolidate_levels bulk update for "+
          Rkanren::KIND_TXT[kind]+" in dict "+
          @dict.dictname+" starting with level #{empty_level}")
      @dict.idioms.where("kind=#{kind} and level in (?)",(empty_level+1)..max_level).update_all("level = level - 1")
    end
    max_level -= 1
    @dict.update_max_level(kind,max_level)
    max_level
  end

  def prepare_score_info(old_level,new_level,old_max_level,new_max_level)
    right_arrow=' ⇴ '
    info_string=(
      (old_level != new_level ?
        "Level changed: #{[old_level,new_level].join(right_arrow)} " :
        '') +
      (old_max_level != new_max_level ?
        "Maxlevel changed: #{[old_max_level,new_max_level].join(right_arrow)}" :
        '')
      )
    flash.now[:success]=info_string unless info_string.blank?
  end

end
