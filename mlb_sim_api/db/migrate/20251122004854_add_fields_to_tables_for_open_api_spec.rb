class AddFieldsToTablesForOpenApiSpec < ActiveRecord::Migration[8.0]
  def change
    # Teamsテーブルにmlb_idとlocation_nameを追加
    add_column :teams, :mlb_id, :integer
    add_column :teams, :location_name, :string
    add_index :teams, :mlb_id, unique: true

    # Gamesテーブルにgame_pkカラムを追加（MLB API互換）
    add_column :games, :game_pk, :bigint
    add_index :games, :game_pk, unique: true

    # Inningsテーブルの構造をOpenAPI仕様に合わせて変更
    # half（top/bottom）、runs、hits、errorsを追加
    add_column :innings, :half, :string
    add_column :innings, :runs, :integer, default: 0
    add_column :innings, :hits, :integer, default: 0
    add_column :innings, :errors, :integer, default: 0

    # 既存のvisitor_score、home_scoreは削除せず残す（後方互換性）
  end
end
