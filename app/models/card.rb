class Card < ActiveRecord::Base
  belongs_to :dict

  after_initialize do
  end

end
