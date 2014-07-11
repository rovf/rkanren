class CreateUniqueIds < ActiveRecord::Migration
  def change
    create_table :unique_ids do |t|
      t.string :key, limit: 16
      t.integer :padlength
      t.string :value, limit: 256

      t.timestamps
    end
    add_index :unique_ids, :key
  end
end
