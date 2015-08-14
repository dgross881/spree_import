require "spec_helper"

describe Spree::Admin::ProductImportsController, type: :controller do
  stub_authorization!
  before do 
    @import_attributes = { csv_import_file_name: "foo.csv", csv_import_file_name: "csv", csv_import_file_size: "123" }
  end 

  describe "POST #create" do
    it "redirects to the home page" do
      spree_post :create, spree_product_import: {csv_import_file_name: "filname"}
      expect(flash[:success]).to match(/You have successfuly Imported products/i)
    end
  end


end
