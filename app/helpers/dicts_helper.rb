module DictsHelper

  # Number of cards in a dictionary
  # d : Either an Integer containing the id of the dict, or a dict object
  def n_cards_in_dict(d)
    Card.where(dict_id: to_dict_id(d)).count
  end

  # Returns true, iff the dictionary denoted by d contains at least one Kanji entry
  def has_kanji_entry?(d)
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
    # A card should be asked with higher probability if:
    #   - it wasn't asked for long time
    #   - if it is a difficult card
    # We sort with descending "probability", i.e. cards with
    # high probabilities come first
    cand_vectors.sort! { |v0, v1| v1 <=> v0 }
    logger.debug("Sorted candidate vectors")
    cand_vectors.each { |ve| logger.debug('+++ ' + ve.to_s + '/' + cand_idioms[ve[-1]].repres)}
    selected_card=candidates[cand_vectors[0][-1]] # DUMMY . We need to do a clever random selection here
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
    # TO DO: Add difficulty of card
    [
      # Exclude very recently asked cards if possible
      has_been_asked_recently ? 0 : 1,
      # Include cards which have not been asked for long time, if possible
      has_not_been_asked_for_very_long_time ? 1 : 0,
      has_not_been_asked_for_long_time ? 1 : 0,
      idiom.last_queried_successful ? 0 : 1,
      4711, # additional fields should go here
      orig_pos, # Must come last. Index in original candidates array
    ]
  end
end
