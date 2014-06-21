class User < ActiveRecord::Base

  has_many  :dicts,
            dependent: :destroy

  has_secure_password

  validates :name,
            uniqueness: { case_sensitive: false },
            presence: true,
            length: { minimum: 2, maximum: 24 }

  validates :password, length: {minimum: 4}

  after_initialize do
    self.name=name.strip.downcase unless name.nil?
    self.email=email.strip.downcase unless email.nil?
  end

  def self.guestname
    '{guest}'
  end

  def self.guestpass
    'Emeralda im Himmel'
  end

  def self.admname
    'marvin'
  end

  def self.guest
    # But we really don't need to authenticate the guest user
    guestuser=find_by_name(guestname).authenticate(guestpass)
    retries=3
    while guestuser.nil? && retries > 0
      guestuser=User.new(name: guestname , email:'', password: guestpass)
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
