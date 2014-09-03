class Idiom < ActiveRecord::Base
  belongs_to :card

  # Card must exist before Idiom can be created. Will this
  # always be the case? Otherwise we just can validate the
  # presence of the card id
  validates :card, :presence => true

  # Removing:             uniqueness: true,
  # because it must be unique only within a dictionary.
  # Maybe we can say "uniqueness: { scope: .... }"
  # But the scope would not be the enclosing card, but the dict.
  # Also, we need to put "kind" into consideration.
  # For setting the unique index, see:
  #  http://apidock.com/rails/ActiveRecord/ConnectionAdapters/SchemaStatements/add_index#note_info-953
  validates :repres,
            presence: true,
            length: { minimum: 1}

  validates :level,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :atari,
            presence: true

  amoeba do
    enable
    # include_field :repres
    # include_field :card_id
    # include_field :card
    # include_field :kind
    # include_field :note
    exclude_field :level
    exclude_field :atari
    exclude_field :queried_time
    exclude_field :last_queried_successful
  end

  def count_same_kind_and_level(dict)
    dict.idioms.where(kind: kind, level: level).count
  end

  def update_user_data!(new_rep,new_note)
    update_attributes!(repres: new_rep, note: new_note)
  end

  def score
    "#{level}/#{atari}"
  end

  # Initial level for new idiom. It is calculated for the
  # dictionary where this Idiom belongs to. You can optionally
  # supply your own dict object. There are two reasons, why you
  # might want to do it:
  # - Optimization (call this function for many idioms, where
  #      you already know that they are in the same dict)
  # - During copying (where the Idiom still "belongs" to the
  #      source dict, but you want to calculate it for the
  #      destination dict)
  def initial_level(dict=nil)
    [1,(dict or self.card.dict).max_level(self.kind)].max
  end

  # dict_or_level can be either a dict object or a number.
  # If it is a dict object:
  # See the description of the method initial_level for the
  # explanation of the dict parameter.
  # If it is an integral number:
  # It is the value for the initial level
  def set_default_fields(dict_or_level=nil)
    self.atari=0
    unless dict_or_level.nil? and self.card_id.nil?
      self.level = dict_or_level.is_a?(Fixnum) ? dict_or_level : initial_level(dict_or_level)
    end
    self.queried_time=nil
    self.last_queried_successful=false
    self
  end

  # Note: cid can also be nil. If both cid or newlevel are nil, the level field
  # won't be set
  def self.make_new(kind,cid,rep,note='',newlevel=nil)
    new_idiom=Idiom.new(repres: rep, card_id: cid, note: note, kind: kind)
    new_idiom.set_default_fields(newlevel) # If nil, level is taken from enclosing dict
  end

  # cid is either the id of the owning card, or nil (if the card has not
  # been saved yet)
  def self.make_new_idiom_from_arrays(kind, cid, reparr, notearr, newlevelarr=[nil]*Rkanren::NREPS)
    logger.debug("++++++++++ make_new_idiom_from_arrays "+newlevelarr.inspect)
    make_new(kind,cid,reparr[kind],notearr[kind],newlevelarr[kind])
  end

end
