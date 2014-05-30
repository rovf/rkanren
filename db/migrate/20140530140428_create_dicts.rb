class CreateDicts < ActiveRecord::Migration
  def change
    create_table :dicts do |t|
      t.string :dictname, limit: 16
      t.references :user, index: true
      t.datetime :accessed
      t.string :language, limit: 32
      t.integer :max_level_kanji, limit: 3
      t.integer :max_level_kana, limit: 3
      t.integer :max_level_gaigo, limit: 3

      t.timestamps
    end
    add_index :dicts, :dictname
  end
end
