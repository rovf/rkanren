module DictsHelper

  # Number of cards in a dictionary
  # d : Either an Integer containing the id of the dict, or a dict object
  def n_cards_in_dict(d)
    Card.where(dict_id: to_dict_id(d)).count
  end

  # Returns true, iff the dictionary denoted by d contains at least one Kanji entry
  def has_kanji_entry?(d)
    d.has_kind?(Rkanren::KANJI)
  end
  def has_kanji_entry__obsolete_version?(d)
    Card. joins(:idioms).
        where("dict_id=#{to_dict_id d} and cards.id=idioms.card_id and kind=#{Rkanren::KANJI}").
        count > 0
  end

  def to_dict_id(d)
    d.is_a?(Dict) ? d.id : d
  end

  def choose_card_for_dict(d,kind)
    # We need "references(:idioms)", because the query uses a field from :idioms
    # for testing:
    # ca=Card.includes(:idioms).references(:idioms).where("dict_id=4 and kind=1").to_a
    candidates=Card.
      includes(:idioms).
      references(:idioms).
      where("dict_id=#{to_dict_id d} and kind=#{kind}").to_a
    now=DateTime.now
    # candidates.sort! do |card0,card1|
    #     idioms=[card0,card1].map {|c| c.idioms.first}
    # Instead of sorting the candidates, we sort an array of
    # sort space vectors instead. This has the advantages
    # - the sort space vector needs to be calculated only once for
    #   each candidate card
    # - we will need the vector after it has been calculated, for
    #   debugging purposes.
    cand_idioms = candidates.map {|c| c.idioms.first}
    cand_vectors = cand_idioms.map.with_index { |id,idx| vector_in_sort_space(now,id,idx)}
    # TODO: Remove from cand_vectors those, which have been asked already
    # during the past, say, 3 minutes, as long as the vector does not
    # become empty.
    # TODO: Shortcut, if the vector has length 1
    logger.debug("+++++++ TODO dicts_helper vector optimizations")
    # A card should be asked with higher probability if:
    #   - it wasn't asked for long time
    #   - if it is a difficult card
    # We sort with descending "probability", i.e. cards with
    # high probabilities come first
    cand_vectors.sort! { |v0, v1| v1 <=> v0 }
    logger.debug("Sorted candidate vectors for time #{tsshow(now)} dict: #{d.dictname} kind: #{kind}")
    cand_vectors.each do |ve|
      # The last ve element is the idiom id
      id=cand_idioms[ve[-1]]
      logger.debug('+++ ' + ve.to_s + "/#{id.id}:#{id.repres}(#{id.card_id}) #{tsshow(id.queried_time)}")
    end
    selected_card=candidates[cand_vectors[biased_random(cand_vectors.length)][-1]]
    logger.debug('selected card id='+selected_card.id.to_s)
    selected_card
  end

private

  THE_BEGINNING = DateTime.strptime('0','%s') # start of epoch
  VERY_LONG_TIME_AGO = 14.days
  LONG_TIME_AGO = 1.day
  JUST_RECENTLY = 5.minutes

  def vector_in_sort_space(now,idiom,orig_pos)
    accessed = idiom.queried_time || THE_BEGINNING
    # since_accessed = now - accessed
    has_not_been_asked_for_very_long_time = now.ago(VERY_LONG_TIME_AGO) > accessed
    has_not_been_asked_for_long_time = now.ago(LONG_TIME_AGO) > accessed
    has_been_asked_recently = now.ago(JUST_RECENTLY) <= accessed
    # Low numbers in the vector mean low probability for being selected.
    # Vector elements are compared left to right. The most important
    # criterion should come first.
    [
      # Exclude just recently asked cards if possible
      has_been_asked_recently ? 0 : 1,
      # Include cards which have not been asked for long time, if possible
      has_not_been_asked_for_very_long_time ? 1 : 0,
      has_not_been_asked_for_long_time ? 1 : 0,
      idiom.last_queried_successful ? 0 : 1,
      idiom.level,
      4711, # additional fields should go here
      idiom.atari == 0 ? 0 : 1, # experimental
      orig_pos, # Must come last. Index in original candidates array
    ]
  end

  # choose a random number from 0..(n-1), giving lower numbers higher
  # probability
  def biased_random(n)
    # For the time being, we make the bias hard-coded. Maybe it could
    # become a user property one day.
    # The bias is represented by a constant bias_prob, which is a number
    # greater than 0 and less than 100 (think of it as probability given
    # as a percentage value). bias_prob > 50 gives preference
    # to lower numbers (which is what we want to have), and the larger
    # it is, the stronger is the preference for lower numbers. For
    # bias_prob == 50, all numbers in the range would have, in theory,
    # equal chance, but due to the sloppy implementation of this function,
    # this is only correct if n is a power of 2.
    bias_prob=75
    low=0
    high=n-1
    # A recursive solution would be most elegant, but we have no control
    # over the size of n.
    while low<high
      split=(high+low)/2 # rounded down!
      if rand(100) < bias_prob
        high=split
      else
        low=split
      end
    end
    low
  end

  def verified_dict(dictid=nil)
    @verified_dict_error=nil
    dictid||=params[:id]
    dict = Dict.find_by_id(dictid)
    if dict.nil?
      @verified_dict_error="Dictionary "+dictid.to_s+" does not exist"
    elsif dict.user_id != current_user_id
      @verified_dict_error="You have no right to access to dictionary number "+dictid.to_s
      dict=nil
    end
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
