require 'roo'

class Spree::ProductImport < Spree::Base
  preference :add_products, :boolean, default: false
  preference :update_products, :boolean, default: false

  has_attached_file :csv_import, path: ':rails_root/lib/etc/product_data/data-files/:basename.:extension'
  validates_attachment :csv_import, presence: true, content_type: { content_type: ['application/excel','application/vnd.ms-excel','application/vnd.msexcel','application/pdf','application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','application/vnd.openxmlformats-officedocument.wordprocessingml.document']}

  validates_inclusion_of :preferred_add_products, in: [true], if: lambda {|u| !u.preferred_update_products }
  validates_inclusion_of :preferred_update_products, in: [true], if: lambda {|u| !u.preferred_add_products }

  def add_products!
    import_products
    header = @products_csv.row(1)
    (2..@products_csv.last_row).each do |row|
      product = Spree::ImportProduct.new(Hash[[header, @products_csv.row(row)].transpose])
      product_found = Spree::Product.find_by(slug: product.slug.downcase)
      if product_found
        new_variant = Spree::Variant.new(clean_up_values(product, false))
        new_variant.product = product_found
        new_variant.price = product.price
        add_product_associations(product, new_variant, klass: "Spree::OptionType", value_one:  "option_type_", value_two: "option_value_")
        add_image(product, new_variant)
        new_variant.save!
        add_stock(new_variant, product)
      else
        new_product = Spree::Product.create!(name: product.name, description: product.description,
                                             meta_keywords: "#{product.slug}, #{product.name}",
                                             meta_description: product.meta_description, meta_title: product.meta_title,
                                             price: product.price, cost_price: product.cost_price,
                                             shipping_category: Spree::ShippingCategory.find_or_create_by!(name: product.shipping),
                                             slug: product.slug.downcase, available_on: Time.now.to_date)

        new_product.stores << Spree::Store.find_by_code(product.store) if product.store 
       # add_translations(new_product, product)
        add_product_associations(product, new_product, klass: "Spree::Property", value_one: "property_type_", value_two: "property_value_")
        add_product_associations(product, new_product, klass: "Spree::Taxonomy", value_one: "taxon_", value_two: "taxonomy_")
        if product.qty
          new_variant = Spree::Variant.new(clean_up_values(product, false), price: product.price)
          new_variant.product = new_product
          add_product_associations(product, new_variant, klass: "Spree::OptionType", value_one:  "option_type_", value_two: "option_value_")
          add_image(product, new_variant)
          new_variant.save!
          add_stock(new_variant, product)
        end
      end
    end
  end

  def update_products!
    import_products
    header = @products_csv.row(1)
    (2..@products_csv.last_row).each do |row|
      product = Spree::ImportProduct.new(Hash[[header, @products_csv.row(row)].transpose])
      if product.slug.present?
        update_product = Spree::Product.find_by(slug: product.slug.downcase)
        update_product.update_attributes(clean_up_values(product))
        if product.update_slug.present?
          update_product.update_attributes(slug: product.update_slug)
        end 
        #add_translations(update_product, product)
        add_product_associations(product, update_product, klass: "Spree::Taxonomy", value_one: "taxon_", value_two: "taxonomy_")
        add_product_associations(product, update_product, klass: "Spree::Property", value_one: "property_type_", value_two: "property_value_")
        update_product.save!
      else
        update_variant = Spree::Variant.find_by(sku: product.sku )
        update_variant.update_attributes(clean_up_values(product, false))
        update_variant.price = product.price if product.price.present?
        add_product_associations(product, update_variant, klass: "Spree::OptionType", value_one: "option_type_", value_two: "option_value_")
        add_image(product, update_variant)
        update_variant.save!
        add_stock(update_variant, product)
      end
    end
  end

  private

  def add_product_associations(product, new_object, options={})
    types = product.instance_values.select { |key, value| key.match(/#{options[:value_one]}/) && value.present? }
    values = product.instance_values.select {|key, value| key.match(/#{options[:value_two]}/)  && value.present? }
    if types.present? && values.present?
      hash_types_and_values = Hash[types.values.zip values.values]
      hash_types_and_values.map do |association, value| 
        product_association_case(association, value, new_object, options[:klass])
      end
    end
  end

  def product_association_case(association, value, new_object, klass)
    case klass
    when "Spree::OptionType"
      option_type = find_klass_or_create(association.capitalize, klass, association.capitalize)
      option_value = Spree::OptionValue.find_or_create_by!(option_type: option_type, name: value, presentation: value)
      new_object.product.option_types << option_type if !new_object.product.option_types.include?(option_type)
      new_object.option_values << option_value
    when "Spree::Property"
      property = find_klass_or_create(association.capitalize, klass, association.capitalize)
      Spree::ProductProperty.find_or_create_by(property: property, value: value.to_yaml, product: new_object) if !new_object.properties.include?(property)
    when "Spree::Taxonomy"
      taxonomy = find_klass_or_create(association.capitalize, klass)
      taxon = find_klass_or_create(value.capitalize, "Spree::Taxon")
      taxonomy.taxons << taxon if !taxonomy.taxons.include? taxon
      taxon.products << new_object 
    else 
      raise "Please add the correct klass to options" 
    end 
  end 

  def add_image(product, new_variant)
    if product.image_src
      image = Spree::Image.create!(viewable: new_variant,
                                   attachment_file_name: product.image_alt.present? ? product.image_alt : 'Default',
                                   alt: product.image_alt ? product.image_alt : '')
      image.image_from_url(product.image_src)
      image.save!
    end
  end

  def import_products
    options = {headers: true, header_converters: :symbol, skip_blanks: true, encoding: 'ISO-8859-1', extension: :xlsx }
    @products_csv =  Roo::Spreadsheet.open(self.csv_import.path, options)
  end

  def clean_up_values(product_import, is_product=true)
    klass = is_product ? "Spree::Product".constantize : "Spree::Variant".constantize
    product_import.instance_values.symbolize_keys.reject {|key, value| !klass.attribute_method?(key) || value.nil? }
  end

  def find_klass_or_create(object, constant, presentation=nil)
    klass = constant.constantize
    presentation ? klass.find_or_create_by(name: object, presentation: presentation) : klass.find_or_create_by(name: object)
  end

  def add_stock(new_variant, product)
    new_variant.stock_items.each do |stock_item|
      Spree::StockMovement.create(quantity: product.qty, stock_item: stock_item)
    end
  end

  def add_translations(new_product, product)
    translations = product.instance_values.select { |key, value| key.match(/_cn/) && value.present? }
    if translations
      new_product.update_attributes(name: product.name_cn, description: product.description_cn, locale: :cn)
    end
  end
end
