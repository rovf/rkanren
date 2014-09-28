class Card < ActiveRecord::Base
  belongs_to :dict

  has_many  :idioms,
            -> { order 'kind' }, # This is a lambda expression (executed via .call)
            inverse_of: :card, # Needed for Amoeba when saving a cloned card. Singular form needed!
            dependent: :destroy # , autosave: true, validate: true

  # amoeba gem allows deep cloning (via amoeba_dup)
  # NOTE: exclude_field and nullify doesn't work
  # https://github.com/rocksolidwebdesign/amoeba/issues/36
  amoeba do
    enable
    # exclude_field :dict_id
    nullify :dict_id
  end

  after_initialize do
  end

  def new_idiom_from_arrays(kind,reparr,notearr)
    # Note: id might be nil, if the new card hasn't been saved yet. In this
    # case, the card_id field of the new idiom won't be have a value yet
    # either.
    Idiom.make_new_idiom_from_arrays(kind, id, reparr, notearr, dict.max_levels_for_new_idiom)
  end

  def save_with_idioms(idiom_array=nil)
    saved=true
    idiom_array=self.idioms.to_a if idiom_array.nil?
    begin
      transaction do
        Idiom.transaction do
          logger.debug("saving card")
          save!
          idiom_array.each do |i|
            logger.debug("saving idiom "+Rkanren::KIND_TXT[i.kind])
            i.card_id=id
            i.save!
          end
        end
      end
    rescue Exception => e
      logger.debug("EXCEPTION in save_with_idioms: #{e.message}")
      saved=false
    end
    saved
  end

  def update_user_data(new_usernote,new_reps,new_notes,initial_level)
    updated=true
    begin
      transaction do
        update_attributes!(usernote: new_usernote)
        new_nreps=new_reps[Rkanren::KANJI].length == 0 ? 2 : 3
        Idiom.transaction do
          dict=Dict.find_by_id(self.dict_id)
          idiom_arr=idioms
          old_nreps=idiom_arr.length
          (new_nreps == old_nreps ? new_nreps : 2).times do |kind|
            idiom_arr[kind].update_user_data!(new_reps[kind],new_notes[kind])
          end
          if new_nreps < old_nreps
            # Remove Kanji representation
            idiom_arr[Rkanren::KANJI].destroy!
          elsif old_nreps < new_nreps
            # Create a new Kanji representation
            Idiom.new(
              repres: new_reps[Rkanren::KANJI],
              card_id: idiom_arr[0].card_id,
              kind: Rkanren::KANJI,
              level: initial_level(dict),
              atari: 0,
              note: new_notes[Rkanren::KANJI]).save!
          end
        end
      end
    rescue
      updated=false
    end
    logger.debug("Card.update_user_data : "+updated.to_s)
    updated
  end
end
