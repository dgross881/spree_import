require 'spec_helper'

describe "Products", type: :feature do
  stub_authorization!

  #context "admin will see a linke to upload products" do 
    #before do
      #import = create(:product_import, csv_import: successfull_import, csv_import_content_type: 'text/csv')
      #visit spree.admin_products_path
    #end 

    #it "allows user to import a product" do 
      #expect(page).to have_content("CSV Import")
    #end

    #it "successfully uploads and stores data in the database" do 

    #end
  #end 
end 
