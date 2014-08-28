class UniqueId < ActiveRecord::Base

    validates :key, presence: true, length: {minimum: 1}

  PADCHAR='0'

  def self.generate(key,seed=PADCHAR,padlen=nil)
    result=seed
    transaction do
      uid=UniqueId.find_by_key(key)
      if uid.nil?
        padlength=padlen||0
        result=pad(seed,padlength)
        UniqueId.create!(key: key, value: pad(seed,padlength), padlength: padlength)
      else
        val=uid.value.succ
        uid.update_attributes!(value: val)
        result=pad(val,padlen||uid.padlength)
      end
    end
    result
  end

  def self.gen_tempdict_uid
    generate('TEMPDICT1','T00000')
  end

private

  def self.pad(v,len)
    sz=v.size
    sz >= len ? v :  v + (PADCHAR * (len-sz))
  end

end
