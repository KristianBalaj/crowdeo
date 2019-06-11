class ChangeQuestionmarkInField < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :is_filter?, :is_filter
    rename_column :users, :calendar_sync?, :calendar_sync
  end
end
