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
      parse_to_temp_dict(tempf,tempdict,d)
      # TODO: Destroy tempdict
    end
    tempf.close
    tempf.unlink
  end

private

  def parse_to_temp_dict(tempf,tempdict,targetdict)
    logger.debug('++++++++++ not implemented yet')
  end

end
