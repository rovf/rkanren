require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe DictsController do

  # This should return the minimal set of attributes required to create a valid
  # Dict. As you add validations to Dict, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "dictname" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DictsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all dicts as @dicts" do
      dict = Dict.create! valid_attributes
      get :index, {}, valid_session
      assigns(:dicts).should eq([dict])
    end
  end

  describe "GET show" do
    it "assigns the requested dict as @dict" do
      dict = Dict.create! valid_attributes
      get :show, {:id => dict.to_param}, valid_session
      assigns(:dict).should eq(dict)
    end
  end

  describe "GET new" do
    it "assigns a new dict as @dict" do
      get :new, {}, valid_session
      assigns(:dict).should be_a_new(Dict)
    end
  end

  describe "GET edit" do
    it "assigns the requested dict as @dict" do
      dict = Dict.create! valid_attributes
      get :edit, {:id => dict.to_param}, valid_session
      assigns(:dict).should eq(dict)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Dict" do
        expect {
          post :create, {:dict => valid_attributes}, valid_session
        }.to change(Dict, :count).by(1)
      end

      it "assigns a newly created dict as @dict" do
        post :create, {:dict => valid_attributes}, valid_session
        assigns(:dict).should be_a(Dict)
        assigns(:dict).should be_persisted
      end

      it "redirects to the created dict" do
        post :create, {:dict => valid_attributes}, valid_session
        response.should redirect_to(Dict.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved dict as @dict" do
        # Trigger the behavior that occurs when invalid params are submitted
        Dict.any_instance.stub(:save).and_return(false)
        post :create, {:dict => { "dictname" => "invalid value" }}, valid_session
        assigns(:dict).should be_a_new(Dict)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Dict.any_instance.stub(:save).and_return(false)
        post :create, {:dict => { "dictname" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested dict" do
        dict = Dict.create! valid_attributes
        # Assuming there are no other dicts in the database, this
        # specifies that the Dict created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Dict.any_instance.should_receive(:update).with({ "dictname" => "MyString" })
        put :update, {:id => dict.to_param, :dict => { "dictname" => "MyString" }}, valid_session
      end

      it "assigns the requested dict as @dict" do
        dict = Dict.create! valid_attributes
        put :update, {:id => dict.to_param, :dict => valid_attributes}, valid_session
        assigns(:dict).should eq(dict)
      end

      it "redirects to the dict" do
        dict = Dict.create! valid_attributes
        put :update, {:id => dict.to_param, :dict => valid_attributes}, valid_session
        response.should redirect_to(dict)
      end
    end

    describe "with invalid params" do
      it "assigns the dict as @dict" do
        dict = Dict.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Dict.any_instance.stub(:save).and_return(false)
        put :update, {:id => dict.to_param, :dict => { "dictname" => "invalid value" }}, valid_session
        assigns(:dict).should eq(dict)
      end

      it "re-renders the 'edit' template" do
        dict = Dict.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Dict.any_instance.stub(:save).and_return(false)
        put :update, {:id => dict.to_param, :dict => { "dictname" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested dict" do
      dict = Dict.create! valid_attributes
      expect {
        delete :destroy, {:id => dict.to_param}, valid_session
      }.to change(Dict, :count).by(-1)
    end

    it "redirects to the dicts list" do
      dict = Dict.create! valid_attributes
      delete :destroy, {:id => dict.to_param}, valid_session
      response.should redirect_to(dicts_url)
    end
  end

end
