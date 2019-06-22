class RemoveCalendarSyncFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :calendar_sync, :boolean
  end
end
