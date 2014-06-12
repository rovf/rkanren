class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :dict, index: true
      t.integer :n_repres, limit: 1
      t.text :usernote

      t.timestamps
    end
  end
end
