require 'spec_helper'

describe "dicts/new" do
  before(:each) do
    assign(:dict, stub_model(Dict,
      :dictname => "MyString",
      :user => nil,
      :language => "MyString",
      :max_level_kanji => 1,
      :max_level_kana => 1,
      :max_level_gaigo => 1
    ).as_new_record)
  end

  it "renders new dict form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", dicts_path, "post" do
      assert_select "input#dict_dictname[name=?]", "dict[dictname]"
      assert_select "input#dict_user[name=?]", "dict[user]"
      assert_select "input#dict_language[name=?]", "dict[language]"
      assert_select "input#dict_max_level_kanji[name=?]", "dict[max_level_kanji]"
      assert_select "input#dict_max_level_kana[name=?]", "dict[max_level_kana]"
      assert_select "input#dict_max_level_gaigo[name=?]", "dict[max_level_gaigo]"
    end
  end
end
