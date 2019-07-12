class CreateMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :maps do |t|
      t.string :name
      t.string :lat
      t.string :lng
      t.string :user_id
      t.integer :status

      t.timestamps
    end
  end
end
