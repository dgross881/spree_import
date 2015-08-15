require 'spec_helper'

describe Spree::ProductImport do 
 let!(:product_import) { create(:product_import, csv_import: successfull_import, csv_import_content_type: 'text/csv')}
 let!(:shipping) {create(:shipping_category, name: "Shipping")}
 let!(:option_type) {create(:option_type, name: "Graphic") }
 let!(:taxon) {create(:taxon, name: "The Taxon") }

 
 it { should have_attached_file(:csv_import) }

 describe '.add_product!' do 
   it 'successfully uploads Product data' do 
     product_import.add_products!
     expect(Spree::Product.count).to eq 1 
   end
 end 
end 
