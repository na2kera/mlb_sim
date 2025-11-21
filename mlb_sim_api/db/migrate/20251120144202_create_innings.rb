class CreateInnings < ActiveRecord::Migration[8.0]
  def change
    create_table :innings do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :inning_number
      t.integer :visitor_score
      t.integer :home_score

      t.timestamps
    end
  end
end
