class Card < ActiveRecord::Base
  belongs_to :dict

  has_many  :idioms,
            -> { order 'kind' }, # This is a lambda expression (executed via .call)
            dependent: :destroy

  after_initialize do
  end

end
