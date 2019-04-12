class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|

      t.string :name
      t.string :description
      t.date :start_date
      t.date :end_date
      t.integer :capacity
      t.boolean :is_filter?
      t.date :from_birth_date
      t.string :location_name
      t.string :location_description
      t.float :longitude
      t.float :latitude

      t.integer :author_id

      t.timestamps
    end

    add_foreign_key :events, :users, column: :author_id
  end
end
