class Card < ActiveRecord::Base
  belongs_to :dict

  has_many  :cards,
            dependent: :destroy

  after_initialize do
  end

end
