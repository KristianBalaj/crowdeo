class AddIndices < ActiveRecord::Migration[5.2]
  def change
    add_index(:events, [:created_at, :name], order: {created_at: :desc, name: :asc})
    add_index(:events_gender_filters, :event_id)
    add_index(:event_attendances, :event_id)
    add_index(:event_attendances, :user_id)
    add_index(:events, :name)
    add_index(:events, :author_id)
  end
end
