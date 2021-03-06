class User < ActiveRecord::Base

  has_many  :dicts,
            dependent: :destroy # Maybe we should not do that, but put the dictionaries into guest space instead

  has_secure_password

  validates :name,
            uniqueness: { case_sensitive: false },
            presence: true,
            length: { minimum: 2, maximum: 24 }

  validates :password, length: {minimum: 4}, if: :password

  after_initialize do
    self.name=name.strip.downcase unless name.nil?
    self.email=email.strip.downcase unless email.nil?
  end

  def new_random_password!
    new_pwd = RandomPasswordGenerator.generate(16, :skip_symbols => true, :skip_upper_case => true, :skip_numbers => true) + RandomPasswordGenerator.generate(4, :skip_lower_case => true, :skip_upper_case => true, :skip_symbols => true)
    update_attributes!(password: new_pwd)
    new_pwd
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
    guestuser=find_by_name(guestname)
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
    if guestuser.nil?
      logger.fatal("We are in serious trouble: Guest user can not be created")
    elsif guestuser.password_digest.nil?
      guestuser.update_attributes!(:password => guestpass)
    else
      unless guestuser.authenticate(guestpass)
        logger.error('This is weird: Guest user fails authentification')
      end
    end
    guestuser
  end

  def self.guestid
    guest.id
  end


end
