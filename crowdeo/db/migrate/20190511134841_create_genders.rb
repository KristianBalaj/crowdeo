class CreateGenders < ActiveRecord::Migration[5.2]
  def change
    create_table :genders do |t|
      t.string :gender_tag

      t.timestamps
    end

    add_column :users, :gender_id, :integer
    add_foreign_key :users, :genders, column: :gender_id

  end
end
