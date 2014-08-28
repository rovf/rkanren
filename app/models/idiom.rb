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

  # Initial level for new idiom. This needs to be an instance method,
  # because it will (eventually) depend on the enclosing dictionary.
  def initial_level
    1 # TODO: Place in highest level, not level 1
    # i.e. Dict.find_by_id(....).max_level(self.kind)
  end

  def set_default_fields
    self.atari=0
    self.level=initial_level
    self.queried_time=nil
    self.last_queried_successful=false
    self
  end

  def self.make_new(kind,cid,rep,note='')
    # TODO: Place in highest level, not level 1
    new_idiom=Idiom.new(repres: rep, card_id: cid, note: note, kind: kind)
    new_idiom.set_default_fields
  end

  def self.make_new_idiom_from_arrays(kind,cid,reparr,notearr)
    make_new(kind,cid,reparr[kind],notearr[kind])
  end

end
