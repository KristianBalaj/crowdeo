class CreateEventAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :event_attendances do |t|
      t.integer :user_id
      t.integer :event_id

      t.timestamps
    end

    add_foreign_key :event_attendances, :users, column: :user_id
    add_foreign_key :event_attendances, :events, column: :event_id

  end
end
