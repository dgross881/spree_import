module Spree
  module Admin
   ProductsController.class_eval do 
     before_filter :new_import, :only => [:index]
     

       private 
       def new_import
         @product_import = ProductImport.new
       end 
    end
  end
end 

