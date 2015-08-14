class AddPreferencesToSpreeImport < ActiveRecord::Migration
  def up
    add_column :spree_product_imports, :preferences, :text
  end

  def down
    remove_column :spree_product_imports, :preferences
  end
end
