class AddTimeToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :start_time, :time
    add_column :events, :end_time, :time
    add_column :events, :tags, :text
    add_column :events, :is_free, :boolean
    add_column :events, :is_night, :boolean
  end
end
