class CreateIdioms < ActiveRecord::Migration
  def change
    create_table :idioms do |t|
      t.string :repres, limit: 128
      t.references :card, index: true
      t.integer :kind, limit: 1
      t.text :note
      t.integer :level, limit: 3
      t.integer :atari

      t.timestamps
    end
    add_index :idioms, :repres
  end
end
