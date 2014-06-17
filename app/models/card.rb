class Card < ActiveRecord::Base
  belongs_to :dict

  has_many  :idioms, # order: :kind
            dependent: :destroy

  after_initialize do
  end

end
