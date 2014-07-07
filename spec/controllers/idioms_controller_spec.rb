require 'spec_helper'

describe IdiomsController do

  describe "GET 'update_score'" do
    it "returns http success" do
      get 'update_score'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end

end
