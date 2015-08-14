class Admin::ProductImportsController < Admin::BaseController
  def create
    @product_import = ProductImport.create(params[:product_import])
    flash[:notice] = t('product_import_processing')
    redirect_to admin_products_path
  end
end
