class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :abbreviation
      t.string :league

      t.timestamps
    end
  end
end
