module Spree
  module AdminProductsControllerExtensions
    def index
      @product_import = ProductImport.new
      super
    end 
  end
end

Spree::Admin::ProductsController.prepend Spree::AdminProductsControllerExtensions
