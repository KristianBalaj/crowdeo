class MakeOnlySingleTimeRecordsInEvent < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :start_date, :date
    remove_column :events, :end_date, :date
    remove_column :events, :start_time, :time
    remove_column :events, :end_time, :time

    add_column :events, :start_time, :timestamp
    add_column :events, :end_time, :timestamp
  end
end
