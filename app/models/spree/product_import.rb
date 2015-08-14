require 'csv'

class Spree::ProductImport < ActiveRecord::Base 
  preference :upload_products, :boolean, :default_false
  preference :upload_variants, :boolean, :default_false 

  has_attached_file :csv_import, :path => ":rails_root/lib/etc/product_data/data-files/:basename.:extension"
  validates_attachment :csv_import, presence: true,
	    :content_type => { content_type: 'text/csv' }

  def add_products!
    import_products 

    products = @products_csv.map { |product|  Spree::ImportProduct.new(product)  }

    products.each do |product|
    new_product = Spree::Product.create!(name: product.name, description: product.description,
                                     meta_title: product.meta_title, meta_description: product.meta_description,
                                     meta_keywords: "#{product.slug}, #{product.name}, the Squirrelz",
                                     available_on: Time.zone.now, price: product.price,
                                     shipping_category: Spree::ShippingCategory.find_by!(name: 'Shipping'))

      new_product.tag_list = product.tags
      new_product.slug = product.slug

      add_product_option_type(product, new_product)
      add_product_propery(product, new_product)
      add_product_taxons(product, new_product)
      product.save!
    end
  end

  #repeating too much can try and make this one method 
  def add_product_taxons(product, new_product) 
   if product.taxon.present? 
     seperate_taxons = product.taxon.split(",").map(&:strip)
     taxon = sperate_taxons.map {|taxon| Spree::Taxon.joins(:translations).find_by(name: taxon) }
     new_product.taxons << taxon unless taxon.nil?
   end 
  end 

  def add_product_option_type(product, new_product) 
   if product.option_type.present? 
     product_option = product.option_type.split(",").map(&:strip)
     option_type = product_option.map {|option_type| Spree::OptionType.joins(:translations).find_by(name: product) }
     new_product.option_types << option_type unless option_type.nil?
   end 
  end 

  def add_product_property(product, new_product)
   if product.type.present? 
     product_option = product.type.split(",").map(&:strip)
     type = product_option.map {|product_property| Spree::ProductProperty.joins(:translations).find_by(value: product_property) }
     new_product.product_properties << type unless type.nil?
   end 
  end 

  private 

  def import_products 
    options = {headers: true, header_converters: :symbol, skip_blanks: true}
    @products_csv = CSV.read(self.csv_import.path, options)
  end
end
