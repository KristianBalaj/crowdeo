class TempTables < ActiveRecord::Migration[5.2]
  def change
    create_table :table1 do |t|
      t.timestamps
    end

    create_table :table2 do |t|
      t.timestamps
    end

    create_table :table3 do |t|
      t.timestamps
    end

    create_table :table4 do |t|
      t.timestamps
    end
  end
end
