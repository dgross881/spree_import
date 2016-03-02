require 'spec_helper'
include ActionDispatch::TestProcess

describe "Products", type: :feature do
  stub_authorization!

  context "admin will see a linke to upload products" do 
    before(:all) do
      create(:store)
      @import_path = 'spec/fixtures/product_import.xlsx' 
      @import_translations_path = '/spec/fixtures/product_import.xlsx' 
      @shipping = create(:shipping_category, name: "Shipping")
      @taxonomy = create(:taxonomy, name: "Brand")
      @taxon = create(:taxon, name: "Youxi")
      visit spree.admin_products_path
    end 

    before do
      visit spree.admin_products_path
    end 

    it "allows user to import a product" do 
      expect(page).to have_content("Import")
    end

    it "successfully uploads all the products in the csv file" do 
      check "import-show-button"
      attach_file "product_import_csv_import", @import_path
      check "product_import_preferred_add_products"
      click_button "Import"
      expect(Spree::Product.count).to eq (1)
    end

    #it "successfully uploads product translations" do 
      #check "import-show-button"
      #attach_file "product_import_csv_import", @import_translations_path
      #check "product_import_preferred_add_products"
      #click_button "Import"
      #expect(page).to have_content("You have successfuly Imported products") 
      #product = Spree::Product.first
      #expect(Spree::Product.count).to eq 1 
      #binding.pry
      #expect(product.taxons).to include @taxon
      #expect(product.properties.count).to eq 1 
      #expect(product.price.to_i).to be_within(1).of(2)
    #end
  end 
end 

