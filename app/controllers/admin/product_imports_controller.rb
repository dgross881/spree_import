class Admin::ProductImportsController < Admin::BaseController
  def create
    @product_import = ProductImport.create(params[:product_import])
    if @product_import.save!
      @product_import.add_products!
      flash[:notice] = t('product_import_processing')
      redirect_to admin_products_path
    else 
      flash[:notice] = Spree.t(:import_error)
      redirect_to admin_products_path
    end 
  end
end
