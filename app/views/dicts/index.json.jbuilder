json.array!(@dicts) do |dict|
  json.extract! dict, :id, :dictname, :user_id, :accessed, :language, :max_level_kanji, :max_level_kana, :max_level_gaigo
  json.url dict_url(dict, format: :json)
end
