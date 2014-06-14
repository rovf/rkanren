class Dict < ActiveRecord::Base

  belongs_to  :user
  has_many    :cards,
              dependent: :destroy

  validates  :dictname,
             uniqueness: true,
             presence: true,
             length: { maximum: 64},
             format: { with: /\A\w/ }
  validates  :language,
             presence: true,
             length: { maximum: 14 }
  validates  :user_id,
             presence: true

  [:max_level_kanji,:max_level_kana,:max_level_gaigo].each do |field_sym|
    validates field_sym, presence: true
  end

  before_save do
  end

  after_initialize do
    self.dictname=dictname.strip unless dictname.nil?
    self.language=language.strip unless language.nil?
    self.max_level_kanji=0
    self.max_level_kana=0
    self.max_level_gaigo=0
  end

  # Bring inconsistent dict records in a correct state, and purge
  # illegal entries

  def self.sanitize

    all.each do |d|
      updatep=false
      if d.dictname.blank?
        logger.debug("sanitize: Delete Dict ID "+d.id.to_s)
        d.destroy
        logger.error("sanitize: Destroy failed for Dict ID "+d.id.to_s) unless d.destroyed?
      elsif d.user_id.blank?
        d.user_id=User.guestid
        updatep=true
      elsif d.language.blank?
        d.language='Steirisch'
        updatep=true
      end
      if updatep
        logger.debug("sanitize: Update dictionary "+d.dictname)
        unless d.save
          logger.debug("sanitize: Update failed for dictionary "+d.dictname)
        end
      end
    end

  end

end
