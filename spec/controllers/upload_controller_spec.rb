require 'spec_helper'

describe UploadController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'upload_file'" do
    it "returns http success" do
      get 'upload_file'
      response.should be_success
    end
  end

end
