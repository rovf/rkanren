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


  def update_user_data!(new_rep,new_note)
    update_attributes!(repres: new_rep, note: new_note)
  end

end
