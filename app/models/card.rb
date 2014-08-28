class Card < ActiveRecord::Base
  belongs_to :dict

  has_many  :idioms,
            -> { order 'kind' }, # This is a lambda expression (executed via .call)
            dependent: :destroy

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
    Idiom.make_new_idiom_from_arrays(kind,id,reparr,notearr)
  end

  def save_with_idioms(idioms)
    saved=true
    begin
      transaction do
        Idiom.transaction do
          save!
          idioms.each do |i|
            i.card_id=id
            i.save!
          end
        end
      end
    rescue
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
              level: initial_level,
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
