module Spree
  module AdminProductsControllerExtensions
   before_filter :new_import, :only => [:index]
   

   private 
   def new_import
     @product_import = ProductImport.new
   end 
  end
end

Spree::Admin::ProductsController.prepend Spree::AdminProductsControllerExtensions
