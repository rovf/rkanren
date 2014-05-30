require "spec_helper"

describe DictsController do
  describe "routing" do

    it "routes to #index" do
      get("/dicts").should route_to("dicts#index")
    end

    it "routes to #new" do
      get("/dicts/new").should route_to("dicts#new")
    end

    it "routes to #show" do
      get("/dicts/1").should route_to("dicts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/dicts/1/edit").should route_to("dicts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/dicts").should route_to("dicts#create")
    end

    it "routes to #update" do
      put("/dicts/1").should route_to("dicts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/dicts/1").should route_to("dicts#destroy", :id => "1")
    end

  end
end
