class UploadController < ApplicationController
  def index
    with_verified_dict(params[:dict_id],root_path) do |d|
      @dict=d
    end
  end

  # The "upload" parameter contains the uploaded file.
  def upload_file
    # File will be deleted when the request ends
    tempf=params[:upload].tempfile # Class: Tempfile
    fpath=tempf.path
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
      tempdict=Dict.tempdict(current_user)
      errmsg=nil
      if tempdict.save
        errmsg=parse_to_temp_dict(tempf,tempdict,d)
        tempdict.destroy
      else
        errmsg="Can not create temporary dictionary"
      end
      unless errmsg.nil?
        flash[:error]=errmsg
        redirect_to dict_path(d.id)
      end
    end
    tempf.close
    tempf.unlink
  end

private

  # Reads next non-blank non-comment line. Throws EOFError if there is none.
  def next_line(tempf)
    line=nil
    loop do
      line=tempf.readline.chomp.strip
      break unless line.length == 0 || line[0]=='#'
    end
  end

  # Throws exception if it can't be verified
  def verified_idiom(rep,targetdict,kind)
    rep # TODO: Check that it is not present yet in targetdict
  end

  def parse_to_temp_dict(tempf,tempdict,targetdict)
    errmsg=nil

    begin

        # File header (specifying dictionary version)
        begin
            raise Exception.new("Uncrecognized header. Not a dictionary file") unless tempf.readline.chomp == 'KANREN01'
          rescue EOFError
            raise Exception.new("Empty file")
        end

        loop do

          # The first line in a group is the group header (a colon)
          begin
            # For the first read, EOFError is OK. This occurs when we have trailing empty lines
            # or comment lines in the file
              raise Exception.new("Error in group header (not a colon)") unless next_line(tempf) == ':'
            rescue EOFError
              break
          end

          # Next comes the Kanji representation, or a sole "-" to indicate
          # that we don't have a Kanji representation for this idiom
          kanji_line = next_line
          kanjirep = kanji_line == '-' ? nil : verified_idiom(kanji_line,targetdict,Rkanren::KANJI)

          # Next come Kana representation and local representation
          kanarep = verified_idiom(next_line, targetdict, Rkanren::KANA)
          gaigorep = verified_idiom(next_line, targetdict, Rkanren::GAIGO)

          # Next comes level/atari vector, or a sole "/" to indicate
          # that we don't have this information available yet.
          level_line = next_line # TODO evaluate this line

        end # loop

      rescue EOFError => e
        errmsg="Last idiom in file is incomplete"
      rescue Exception => e
        errmsg=e.message
    end
    logger.debug('++++++++++ not completely implemented yet')
    "Error in line #{tempf.lineno} of uploaded dictionary file:\n"+errmsg
  end

end
