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
    candidates.sort! do |card0,card1|
        idioms=[card0,card1].map {|c| c.idioms.first}
        # A card should be asked with higher probability if:
        #   - it wasn't asked for long time
        #   - if it is a difficult card
        # We sort with descending "probability"
        vector_in_sort_space[now,idioms[0]] <=> vector_in_sort_space[now,idioms[1]]
      end
    candidates.first # DUMMY . We need to do a clever random selection here
  end

private

  THE_BEGINNING = DateTime.strptime('0','%s') # start of epoch
  VERY_LONG_TIME_AGO = 14.days
  LONG_TIME_AGO = 1.day
  JUST_RECENTLY = 5.minutes

  def vector_in_sort_space(now,idiom)
    accessed = idiom.accessed || THE_BEGINNING
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
    ]
  end
end
