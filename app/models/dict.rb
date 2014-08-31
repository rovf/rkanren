class Dict < ActiveRecord::Base

  DICTNAME_MAXLEN=16

  belongs_to  :user
  has_many    :cards,
              dependent: :destroy
  has_many :idioms, through: :cards

  validates  :dictname,
             uniqueness: true,
             presence: true,
             length: { maximum: DICTNAME_MAXLEN},
             format: { with: /\A\w/ }
  validates  :language,
             presence: true,
             length: { maximum: 32 }
  validates  :user_id,
             presence: true

  [:max_level_kanji,:max_level_kana,:max_level_gaigo].each do |field_sym|
    validates field_sym, presence: true
  end

  # This string MUST be of length 1. A dictionary staring with
  # this character is an internal dictionary.
  SIGIL_INTERNAL_DICT='_'

  before_save do
  end

  after_initialize do
    self.dictname=dictname.strip unless dictname.nil?
    self.language=language.strip unless language.nil?
    Rkanren::KINDS.each do |kind|
      kind_field_name=Dict.field_name_max_kind(kind)
      self[kind_field_name]=0 if self[kind_field_name].nil?
    end
  end

  def has_kind?(kind)
    idioms.where(kind: kind).exists?
  end

  def max_level(kind)
    self[Dict.field_name_max_kind(kind)]
  end

  def max_levels_for_new_idiom
    Rkanren::KINDS.map { |kind| [max_level(kind),1] }
  end

  def update_max_level!(kind,new_level)
    update_attributes!(Dict.field_name_max_kind(kind) => new_level)
  end

  # Returns a Set of card ids, where one of the definitions in
  # card are already in this dictionary
  def clashing_with(card)
    result=Set.new # no require 'set' needed (already included)
    card_idioms=card.idioms
    Rkanren::KINDS.each do |k|
      result.merge(idioms.where(kind: k, repres: card_idioms[k].repres).map { |idiom| idiom.card_id }) if card_idioms[k]
    end
    result
  end

  # Create temporary dictionary for user
  def self.tempdict(user)
    tempname=(SIGIL_INTERNAL_DICT+UniqueId.gen_tempdict_uid+'_'+user.name)[0,DICTNAME_MAXLEN]
    user.dicts.build(dictname:tempname,language:'Elbisch')
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
      end
      unless d.destroyed?
        if d.user_id.blank?
          d.user_id=User.guestid
          logger.debug("sanitize dictionary #{d.dictname}, assign to guest user")
          updatep=true
        end
        if d.language.blank?
          logger.debug("sanitize dictionary #{d.dictname} of user #{d.user.name}, assign language")
          d.language='Steirisch'
          updatep=true
        end
        if d.cards.exists?
          Rkanren::KINDS.each do |k|
            if d.max_level(k)==0 and d.has_kind?(k)
              new_max_level=d.idioms.where(kind:k).map {|i| i.level}.max
              if new_max_level > 0
                d[Dict.field_name_max_kind(k)]=new_max_level
                logger.debug("sanitize dictionary #{d.dictname} in language #{d.language}, set max level for #{Rkanren::KIND_TXT[k]} to #{new_max_level}")
                updatep=true
              end
            end
          end
        end
      end
      if updatep
        logger.debug("sanitize: Update dictionary "+d.dictname)
        unless d.save
          logger.debug("sanitize: Update failed for dictionary "+d.dictname)
        end
      end
    end

  end

private

  def self.field_name_max_kind(kind)
    'max_level_'+Rkanren::KIND_TXT[kind]
  end

end
