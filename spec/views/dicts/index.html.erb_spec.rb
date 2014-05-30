require 'spec_helper'

describe "dicts/index" do
  before(:each) do
    assign(:dicts, [
      stub_model(Dict,
        :dictname => "Dictname",
        :user => nil,
        :language => "Language",
        :max_level_kanji => 1,
        :max_level_kana => 2,
        :max_level_gaigo => 3
      ),
      stub_model(Dict,
        :dictname => "Dictname",
        :user => nil,
        :language => "Language",
        :max_level_kanji => 1,
        :max_level_kana => 2,
        :max_level_gaigo => 3
      )
    ])
  end

  it "renders a list of dicts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Dictname".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Language".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
