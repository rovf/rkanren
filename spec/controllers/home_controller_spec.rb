require 'spec_helper'

describe HomeController do

  describe "GET 'init'" do
    it "returns http success" do
      get 'init'
      response.should be_success
    end
  end

end
