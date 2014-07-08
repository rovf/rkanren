class UploadController < ApplicationController
  def index
  end

  # The "upload" parameter contains the uploaded file.
  def upload_file
    # File will be deleted when the request ends
    tempf=params[:upload].tempfile # Class: Tempfile
    fpath=tempf.path
    logger.debug('+++++++++++ tempfile '+fpath)
    # TODO: Think about the following algorithm. Maybe we can do
    # the "merging" easier by just changing the dict_id in the
    # card objects.
    # - parse the file, store values into a temporary dict object
    # - if successful, merge the temporary dict object into the current one
    # - otherwise generate error message
    # - delete the temporary dict object
    parse_to_temp_dict(tempf)
    tempf.close
    tempf.unlink
  end

private

  def parse_to_temp_dict(tempf)
    logger.debug('++++++++++ not implemented yet')
  end

end
