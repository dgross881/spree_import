require 'csv'

class Spree::ProductImport < ActiveRecord::Base 
  has_attached_file :csv_import, :path => ":rails_root/lib/etc/product_data/data-files/:basename.:extension"
  validates_presence_of :csv_import


  def add_products!
    import_products 

    products = @products_csv.foreach { |product|  ImportProduct.new(product)  }

    products.each do |product|
    product = Spree::Product.create!(name: product.name, description: product.description,
                                     meta_title: product.meta_title, meta_description: product.meta_description,
                                     meta_keywords: "#{product.slug}, #{product.name}, the Squirrelz",
                                     available_on: Time.zone.now, price: product.price,
                                     shipping_category: Spree::ShippingCategory.find_by!(name: 'Shipping'))
      product.tag_list = @tags
      product.slug = @slug
      product.save!
    end
  end

  def import_products 
    options = {headers: true, header_converters: :symbol, skip_blanks: true}
    @products_csv = CSV.read(Rails.root.join(self.csv_import.data, options))
  end
end 
