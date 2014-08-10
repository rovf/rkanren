class AddWorldReadableToDicts < ActiveRecord::Migration
  def change
    add_column :dicts, :world_readable, :boolean
  end
end
