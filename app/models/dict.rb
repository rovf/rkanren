class Dict < ActiveRecord::Base
  belongs_to :user
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

end
