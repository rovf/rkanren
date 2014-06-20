class Idiom < ActiveRecord::Base
  belongs_to :card

  # Card must exist before Idiom can be created. Will this
  # always be the case? Otherwise we just can validate the
  # presence of the card id
  validates :card, :presence => true

  validates :repres,
            uniqueness: true,
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
