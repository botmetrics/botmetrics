class ChangeQuerySetIdColumnNullToFalse < ActiveRecord::Migration
  def change
    change_column_null :queries, :query_set_id, false
  end
end
