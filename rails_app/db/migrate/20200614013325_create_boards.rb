class CreateBoards < ActiveRecord::Migration[5.2]
  def change
    create_table :boards do |t|
      t.string :my_hash
      t.text :draw_data
      t.integer :user_id # Need for "belongs_to"
      t.timestamps
    end
  end
end
