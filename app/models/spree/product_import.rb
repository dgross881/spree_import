require 'csv'

class Spree::ProductImport < ActiveRecord::Base 
  preference :upload_products, :boolean, :default_false
  preference :upload_variants, :boolean, :default_false 

  has_attached_file :csv_import, :path => ":rails_root/lib/etc/product_data/data-files/:basename.:extension"
  validates_attachment :csv_import, presence: true,
	    :content_type => { content_type: 'text/csv' }

  def add_products!
    import_products 

    products = @products_csv.foreach { |product|  ImportProduct.new(product)  }

    products.each do |product|
    product = Spree::Product.create!(name: product.name, description: product.description,
                                     meta_title: product.meta_title, meta_description: product.meta_description,
                                     meta_keywords: "#{product.slug}, #{product.name}, the Squirrelz",
                                     available_on: Time.zone.now, price: product.price,
                                     shipping_category: Spree::ShippingCategory.find_by!(name: 'Shipping'))

      product.tag_list = product.tags
      product.slug = product.slug
      product.option_types << product.option_type unless product.option_type.nil?
      product.properties << product.type unless product.type.nil? 
      add_product_taxons(product)
      product.save!
    end
  end

  def add_product_taxons(product) 
   if product.taxon.present? 
     seperate_taxons = product.taxon.split(",").map(&:strip)
     taxon = sperate_taxons.map {|product| Spree::Taxon.joins(:translations).find_by(name: product) }
     product.taxons << taxon unless taxon.nil?
   end 
  end 

  private 

  def import_products 
    options = {headers: true, header_converters: :symbol, skip_blanks: true}
    @products_csv = CSV.read(self.csv_import.path, options)
  end
end
