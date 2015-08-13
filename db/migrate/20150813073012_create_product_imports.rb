class CreateProductImports < ActiveRecord::Migration
  def change
    create_table :spree_product_imports do |t|
      t.string :csv_import_file_name
      t.string :csv_import_content_type
      t.integer :csv_import_file_size
      t.datetime :csv_import_updated_at
      t.timestamps
    end
  end
end
