class RenameErrorsToErrorCountInInnings < ActiveRecord::Migration[8.0]
  def change
    rename_column :innings, :errors, :error_count
  end
end
