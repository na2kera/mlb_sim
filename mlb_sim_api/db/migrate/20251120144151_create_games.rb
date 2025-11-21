class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.datetime :date
      t.string :status
      t.references :home_team, null: false, foreign_key: {to_table: :teams}
      t.references :visitor_team, null: false, foreign_key: {to_table: :teams}

      t.timestamps
    end
  end
end
