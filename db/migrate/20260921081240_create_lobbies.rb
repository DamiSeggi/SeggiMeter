class CreateLobbies < ActiveRecord::Migration[8.1]
  def change
    create_table :lobbies do |t|
      t.string :title, null: false
      t.references :user, null: false, foreign_key: true
      t.references :locked_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
