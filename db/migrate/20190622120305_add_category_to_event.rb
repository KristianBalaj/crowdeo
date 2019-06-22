class AddCategoryToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :category_id, :integer
    add_foreign_key :events, :categories, column: :category_id
    remove_column :events, :location_name, :string
    remove_column :events, :location_description, :string
  end
end
