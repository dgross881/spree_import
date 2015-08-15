require 'csv'

class Spree::ProductImport < Spree::Base 
  preference :upload_products, :boolean, :default_false
  preference :upload_variants, :boolean, :default_false 

  has_attached_file :csv_import, :path => ":rails_root/lib/etc/product_data/data-files/:basename.:extension"
  validates_attachment :csv_import, presence: true,
	    :content_type => { content_type: 'text/csv' }

  def add_products!
    import_products 

    products = @products_csv.map { |product|  Spree::ImportProduct.new(product)  }

    products.each do |product|

    new_product = Spree::Product.create!(name: product.name.split, description: product.description.split,
                                     meta_title: product.meta_title.split, meta_description: product.meta_description.split,
                                     meta_keywords: "#{product.slug.split}, #{product.name.split}, the Squirrelz",
                                     available_on: Time.zone.now, price: product.price,
                                     shipping_category: Spree::ShippingCategory.find_by!(name: 'Shipping'))

      #new_product.tag_list = product.tags
      new_product.slug = product.slug

      add_product_option_type(product, new_product)
      add_product_property(product, new_product)
      add_product_taxons(product, new_product)
      new_product.save!
    end
  end

  #repeating too much can try and make this one method 
  def add_product_taxons(product, new_product) 
   if product.taxons.present? 
     seperate_taxons = product.taxons.split(",").map(&:strip)
     taxon = seperate_taxons.map {|taxon_name| Spree::Taxon.find_by(name: taxon_name) }
     unless taxon.nil? 
       new_product.taxons << taxon 
     end 
   end 
  end 

  def add_product_option_type(product, new_product) 
   if product.option_type.present? 
     product_option = product.option_type.split(",").map(&:strip)
     option_type = product_option.map {|option_type| Spree::OptionType.find_by(name: option_type) }
     new_product.option_types << option_type unless option_type.nil?
   end 
  end 

  def add_product_property(product, new_product)
   if product.type.present? 
     product_option = product.type.split(",").map(&:strip)
     type = product_option.map {|property| find_property(property) }
     if find_property(type).present?
       new_product.product_properties << type 
     end 
   end 
  end 

  private 

  def find_property(property)
    Spree::ProductProperty.find_by(value: property)
  end 

  def import_products 
    options = {headers: true, header_converters: :symbol, skip_blanks: true}
    @products_csv = CSV.read(self.csv_import.path, options)
  end
end
