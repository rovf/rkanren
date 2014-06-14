class User < ActiveRecord::Base

  has_many  :dicts,
            dependent: :destroy

  validates :name,
            uniqueness: { case_sensitive: false },
            presence: true,
            length: { minimum: 2, maximum: 24 }

  after_initialize do
    self.name=name.strip.downcase unless name.nil?
    self.email=email.strip.downcase unless email.nil?
  end

  def self.guestname
    '{guest}'
  end

  def self.guest
    guestuser=find_by_name(guestname)
    retries=3
    while guestuser.nil? && retries > 0
      guestuser=User.new(name: guestname , email:'')
      if guestuser.save
        logger.debug("Created user "+guestname)
      else
        logger.debug("Failed to created "+guestname+", retry")
        guestuser=nil
        sleep(2)
        retries-=1
      end
    end
    guestuser
  end

  def self.guestid
    guest.id
  end

end
