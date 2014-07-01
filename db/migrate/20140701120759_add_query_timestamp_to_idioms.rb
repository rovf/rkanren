class AddQueryTimestampToIdioms < ActiveRecord::Migration
  def change
    add_column :idioms, :queried_time, :datetime, default: DateTime.now
    add_column :idioms, :last_queried_successful, :boolean, default: false
  end
end
