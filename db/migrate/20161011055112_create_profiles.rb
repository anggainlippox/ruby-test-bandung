class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :directories
      t.string :exclusions
      t.string :storage_directory
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
