module Spree
  module  Admin
    class ProductImportsController < Spree::Admin::BaseController

      def create
        @product_import = Spree::ProductImport.create(csv_import_params)
        if @product_import.save
          @product_import.upload_products!
          flash[:success] = "You have successfuly Imported products" 
          redirect_to admin_products_path
        else 
          flash[:error] =  "There was an error validating your file please check it"
          redirect_to admin_products_path
        end 
      end

      def csv_import_params
        params.fetch(:product_import, {}).permit(:csv_import)
      end 
    end 
  end 
end
