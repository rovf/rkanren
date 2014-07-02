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
    candidates=Card.joins(:idioms).where("dict_id=#{to_dict_id d} and kind=#{kind}").sort do |a,b|
      logger.debug("+++++++ inside sort: "+a.inspect)
    end
  end

end
