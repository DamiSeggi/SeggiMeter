class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lobby, null: false, foreign_key: true
      t.string :word, null: false

      t.timestamps
    end
  end
end
