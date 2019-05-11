class CreateEventsGenderFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :events_gender_filters do |t|
      t.integer :event_id
      t.integer :gender_id

      t.timestamps
    end

    add_foreign_key :events_gender_filters, :events, column: :event_id
    add_foreign_key :events_gender_filters, :genders, column: :gender_id

  end
end
