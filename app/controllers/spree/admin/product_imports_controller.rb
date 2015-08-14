module Spree
  module  Admin
    class ProductImportsController < Spree::Admin::BaseController

      def create
        @product_import = Spree::ProductImport.create(csv_import_params)
        if @product_import.save!
          @product_import.upload_products!
          flash[:success] = "You have successfuly Imported products" 
          redirect_to admin_products_path
        else 
          flash[:error] = Spree.t(:import_error)
          redirect_to admin_products_path
        end 
      end


      def csv_import_params
        params.require(:spree_product_import).permit(:csv_import)
      end 
    end 
  end 
end
