class UploadController < ApplicationController

  def index
    with_verified_dict(params[:dict_id],root_path) do |d|
      @dict=d
    end
  end

  def confirm_import
    with_verified_dict(params[:dict_id],root_path) do |target_dict|
      @dict=target_dict
      @from_dict=Dict.find_by_id(params[:id])
      if @from_dict.nil?
          flash[:error]="The selected directory does not exist anymore"
          redirect_to dict_select_for_import_path(target_dict.id)
      else
        render
      end
    end
  end

  # params:
  #  dict_id : the dictionary which receives the new idioms
  #  id : the dictionary where the new idioms come from
  #  duplicates : What to do with duplicate terms. Only "ignore"
  #            and "overwrite" are permitted.
  #  proceed : If this key is present, import should be performed
  #  cancel : If this key is present, the user decided to cancel the operation
  def import_dict
      with_verified_dict(params[:dict_id],root_path) do |target_dict|
        if params.has_key?(:cancel)
          flash[:notice]="Nothing imported, because you have decided to cancel the operation"
          redirect_to dict_select_for_import_path(target_dict.id)
        else
          @dict=target_dict
          source_dict=Dict.find_by_id(params[:id])
          if source_dict.nil?
            flash[:error]="The selected directory does not exist anymore"
            redirect_to dict_select_for_import_path(target_dict.id)
          elsif source_dict.world_readable or source_dict.user_id == current_user_id
            duplicates_treatment=(params[:duplicates]||'reject').to_sym
            # No need to do a transaction here. If import aborts for whatever reason,
            # the user can simply rerun it.
            @merge_status = dict_merge(target_dict,source_dict,duplicates_treatment)
            if @merge_status[:n_added] == 0 && @merge_status[:n_errors] == 0
              # Imported dictionary empty, or maybe only entries which are
              # already present. Let user choose a different dictionary.
              flash[:warning]="Dictionary does not contain anything which can be imported."
              redirect_to dict_select_for_import_path(target_dict.id)
            else
              if @merge_status[:n_errors] > 0
                flash[:error] =
                  "Dictionary merge was " +
                  (@merge_status[:n_added] == 0 ? "not" : "only partially")+
                  " successful"
              else
                flash[:success] = "Dictionary imported"
              end
              # @merge_status contains result of Upload
              # TODO: But the view doesn't know the controller
              #       object and hence can't access the controller's
              #       data.
              @dict=target_dict
              logger.debug("########## "+@merge_status.inspect)
              render 'import_show_result'
              # redirect_to dict_import_show_result_path(target_dict.id)
            end
          else
            logger.warn("Someone is trying to steal a dictionary! current user = #{current_user_id}")
            redirect_to root_path
          end
        end
      end
  end

  # The "upload" parameter contains the uploaded file.
  # The "duplicates" parameter indicates what should happen with
  # idioms, which occur in both the uploaded file and the dictionary.
  # Possible values:
  #     "reject" - reject the whole upload, if a duplicate is found
  #     "ignore" - skip the idiom, if it is already in the dictionary
  #     "overwrite" - overwrite the idiom in the dictionary with the new value
  def upload_file
    # TODO: Think about the following algorithm. Maybe we can do
    # the "merging" easier by just changing the dict_id in the
    # card objects.
    # - parse the file, store values into a temporary dict object
    # - if successful, merge the temporary dict object into the current one
    # - otherwise generate error message
    # - delete the temporary dict object
    # IMPORTANT: The new words should have the level of the imported
    # dictionary, if the target dictionary is empty, and to
    # maxlevel, if it is not. The latter should be (later) made
    # a user's choice. Don't forget to update max_level_kanji etc.
    # in the Dict instance.
    with_verified_dict(params[:dict_id],root_path) do |d|
      @dict=d
      # Check for CANCEL button
      if params.has_key?('cancel')
        redirect_to dict_path(d.id)
      else
        if params[:upload].nil?
          flash.now[:error]="No file selected"
          render 'index'
        else
          # File will be deleted when the request ends
          tempf=params[:upload].tempfile # Class: Tempfile
          fpath=tempf.path
          # tempf.set_encoding('BOM|UTF-8')
          tempf=File.open(fpath,'r:BOM|UTF-8')
          tempdict=Dict.tempdict(current_user)
          errmsg=nil
          if tempdict.save
            errmsg=parse_to_temp_dict(tempf, tempdict, d, (params[:duplicates]||'reject').to_sym)
            if errmsg.nil?
              temp_dict_merge(tempdict, d)
              flash[:success]="Upload sucessful"
            end
            # Dict.find_by_id(tempdict.id).destroy
            tempdict.reload.destroy # Reload gets rid of re-assigned cards
          else
            errmsg="Can not create temporary dictionary"
          end
          tempf.close
          # tempf.unlink # unlink is instance method only for Tempfile, not for File
          File.unlink(fpath)
          unless errmsg.nil?
            flash[:error]=errmsg
          end
          redirect_to dict_path(d.id)
        end
      end
    end
  end

private

  # Reads next non-blank non-comment line. Throws EOFError if there is none.
  def next_line(tempf)
    line=nil
    loop do
      line=tempf.readline.chomp.strip
      logger.debug("++++++ READ #{line.length} 字: ["+line+']')
      break unless line.length == 0 || line[0]=='#'
      logger.debug("++++++ (IGNORED)")
    end
    line
  end

  # Throws exception if it can't be verified.
  # Returns the null string if this idiom should be ignored.
  def verified_idiom(rep, targetdict, kind, duplicates_treatment)
    unless duplicates_treatment == :overwrite
      # See whether this idiom already exists
      if targetdict.idioms.where('repres = ? and kind = ?',rep,kind).length > 0
        if duplicates_treatment == :reject
          raise Exception.new("#{Rkanren::KIND_PP} Idiom already in dictionary: #{rep}")
        else
          logger.debug("Idiom of type #{Rkanren::KIND_TXT[kind]} ignoren (already in dictionary #{targetdict.dictname}): #{rep}")
          rep=''
        end
      end
    end
    rep
  end

  # Verify dictionary header (containing dictionary filetype).
  # Throws exception on error.
  def verify_header(tempf)
    begin
        raise Exception.new("Uncrecognized header. Not a dictionary file") unless tempf.readline.chomp == 'KANREN01'
      rescue EOFError
        raise Exception.new("Empty file")
    end
  end

  # Verify the header of an idiom group. Throws exception on error.
  # Returns false on EOF. Returns true on new group.
  def verify_group_header(tempf)
    start_of_new_group=true
    begin
        # For the first read, EOFError is OK. This occurs when
        # we have trailing empty lines or comment lines in the file
        raise Exception.new("Error in group header (not a colon)") unless next_line(tempf) == ':'
      rescue EOFError
        start_of_new_group=false
    end
    start_of_new_group
  end

  # Returns error message in case of error, or nil if no error
  def parse_to_temp_dict(tempf, tempdict, targetdict, duplicates_treatment)

    errmsg=nil # return value

    begin

        verify_header(tempf)

        loop do

          # The first line in a group is the group header (a colon)
          break unless verify_group_header(tempf)

          # Next comes the Kanji representation, or a sole "-" to indicate
          # that we don't have a Kanji representation for this idiom
          kanji_line = next_line(tempf)
          kanjirep = kanji_line == '-' ? nil : verified_idiom(kanji_line, targetdict, Rkanren::KANJI, duplicates_treatment)

          # Next come Kana representation and local representation
          kanarep = verified_idiom(next_line(tempf), targetdict, Rkanren::KANA, duplicates_treatment)
          gaigorep = verified_idiom(next_line(tempf), targetdict, Rkanren::GAIGO, duplicates_treatment)

          # Next comes level/atari vector, or a sole "/" to indicate
          # that we don't have this information available yet.
          level_line = next_line(tempf) # TODO evaluate this line

          next if (kanjirep||'-').empty? or kanarep.empty? or gaigorep.empty?

          newcard=tempdict.cards.create!(n_repres: kanjirep.nil? ? 2 : 3)
          # TODO: Fix level and atari
          newcard.idioms.create!(repres: kanjirep, kind: Rkanren::KANJI, level: 0, atari: 0) unless kanjirep.nil?
          newcard.idioms.create!(repres: kanarep, kind: Rkanren::KANA, level: 0, atari: 0)
          newcard.idioms.create!(repres: gaigorep, kind: Rkanren::GAIGO, level: 0, atari: 0)

          logger.debug("Processed with"+(kanjirep.nil? ? 'out' : '')+':['+gaigorep+']')

        end # loop

      rescue EOFError => e
        errmsg="Last idiom in file is incomplete"
      rescue RuntimeError
        raise
      rescue Exception => e
        errmsg=e.message
    end

    logger.debug('++++++++++ not completely implemented yet (atari/level handling)')
    "Error in line #{tempf.lineno} of uploaded dictionary file:\n"+errmsg unless errmsg.nil?

    errmsg
  end

  def dict_merge(into_dict,from_dict,duplicates_treatment)
    # As a backup, duplicates are stored in a temporary dictionary
    tempdict=nil
    added=0
    ignored=0
    with_errors=0
    errmsg=''
    max_levels_for_new_idiom=nil
    logger.debug("++++++++++ dict_merge #{from_dict.cards.count} cards from #{from_dict.dictname} into #{into_dict.dictname}")
    from_dict.cards.each do |c|
      add_this_card=true
      clashing=into_dict.clashing_with(c)
      unless clashing.empty?
        # We have overlapping definition
        if duplicates_treatment == :overwrite
          # Delete duplicates before adding new card
          tempdict=Dict.tempdict(current_user) if tempdict.nil?
          clashing.each do |cardid|
            card_to_delete=Card.find_by_id(cardid)
            card_to_delete.update_attributes!(dict_id: tempdict.id) unless card_to_delete.nil? or card_to_delete.dict_id == tempdict.id
          end
        else
          logger.debug("dict_merge: ignore card #{c.id}, duplicate found at #{clashing.to_a}")
          add_this_card=false
          ignored += 1
        end
      end
      if add_this_card
        cloned_card=c.amoeba_dup
        cloned_card.dict_id=into_dict.id
        max_levels_for_new_idiom ||= into_dict.max_levels_for_new_idiom
        cloned_card.idioms.all do |idiom|
          idiom.set_default_fields(max_levels_for_new_idiom[idiom.kind])
        end
        if cloned_card.save
          added += 1
        else
          with_errors += 1
          ignored += 1
          errmsg += "Error #{with_errors} - '#{cloned_card.idioms[Rkanren::GAIGO]}'"
          ([cloned_card]+cloned_card.idioms.to_a).each do |record|
            errmsg += "\n"+record.errors.full_messages.to_sentence if record.errors
          end
        end
      end # add_this_card
    end
    # :deleted_duplicates is nil, if no cards have been deleted
    { :deleted_duplicates => tempdict,
      :n_added => added,
      :n_ignored => ignored,
      :n_errors => with_errors,
      :errorstring => errmsg }
  end

  def temp_dict_merge(tempdict,targetdict)
    targetdict_id=targetdict.id
    targetdict.transaction do
      logger.debug("+++++++++ merging from #{tempdict.dictname} into #{targetdict.dictname}")
#      cards_to_add=tempdict.cards.to_a
#      tempdict.cards=[]
#      targetdict.cards += cards_to_add
      tempdict.cards.each do |c|
        c.update_attributes!(dict_id: targetdict_id)
        logger.debug("+++++++ merged: "+c.idioms.first.repres)
      end
    end
  end

end
