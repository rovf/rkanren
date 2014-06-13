class Idiom < ActiveRecord::Base
  belongs_to :card

  validates :repres,
            uniqueness: true,
            presence: true,
            length: { minimum: 1}

  validates :level,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :atari,
            presence: true

end
