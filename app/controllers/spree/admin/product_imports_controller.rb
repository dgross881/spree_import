module Spree
  module  Admin
    class ProductImportsController < Spree::Admin::BaseController
      def create
        @product_import = Spree::ProductImport.create(csv_import_params)
        if @product_import.save
          add_or_update_products

          flash[:success] = 'You have successfuly Imported products'
          redirect_to admin_products_path
        else 
          flash[:error] =  @product_import.errors 
          redirect_to admin_products_path
        end 
      end

    private
    
      def add_or_update_products
        if @product_import.preferred_update_products
          @product_import.update_products!
        else 
          @product_import.add_products!
        end 
      end 

      def csv_import_params
        params.fetch(:product_import, {}).permit(:csv_import, :preferred_add_products, :preferred_update_products)
      end 
    end 
  end 
end 
