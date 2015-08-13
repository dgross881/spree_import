class Spree::ProductImport < ActiveRecord::Base 
  has_attached_file :csv_import, :path => ":rails_root/lib/etc/product_data/data-files/:basename.:extension"
  validates_presence_of :csv_import 
end 
