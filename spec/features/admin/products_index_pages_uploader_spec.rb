require 'spec_helper'

describe "Products", type: :feature do
  stub_authorization!

  context "admin will see a linke to upload products" do 
    before do
      visit spree.admin_products_path
    end 

    it "allows user to import a product" do 
      expect(page).to have_content("Csv Import")
    end
  end 
end 
