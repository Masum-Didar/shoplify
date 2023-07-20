class AddSalesCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :sales_count,:integer, null: false, default: 0
  end
end
