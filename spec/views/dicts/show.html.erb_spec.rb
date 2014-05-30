require 'spec_helper'

describe "dicts/show" do
  before(:each) do
    @dict = assign(:dict, stub_model(Dict,
      :dictname => "Dictname",
      :user => nil,
      :language => "Language",
      :max_level_kanji => 1,
      :max_level_kana => 2,
      :max_level_gaigo => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Dictname/)
    rendered.should match(//)
    rendered.should match(/Language/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
