require 'csv'

class Spree::ProductImport < ActiveRecord::Base 
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
      product.save!

      add_variants
    end
  end

  def add_variants 
    variant = Spree::Variant.create!(stock_items_count: product.qty, cost_price: product.price, weight: product.weight,
                                     product: Spree::Product.find_by()
    unless product.option1.blank?
      variant.option_values << Spree::OptionValue.joins(:translations).find_by!(name: row['option1'])
    end
    unless product.option2.blank?
      variant.option_values << Spree::OptionValue.joins(:translations).find_by!(name: row['option2'])
    end
    variant.save!
  end

  def import_products 
    options = {headers: true, header_converters: :symbol, skip_blanks: true}
    @products_csv = CSV.read(self.csv_import.path, options)
  end
end 
