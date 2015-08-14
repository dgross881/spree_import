module Spree
  module AdminProductsControllerExtensions
    def index  
      @product_import = ProductImport.create(params[:product_import])
      super 
    end 
  end
end

Spree::Admin::ProductsController.prepend Spree::AdminProductsControllerExtensions
