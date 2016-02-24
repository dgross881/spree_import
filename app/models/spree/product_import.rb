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
        new_variant = Spree::Variant.new(clean_variant(product))
        new_variant.product = product_found
        new_variant.price = product.price
        add_option_type(product, new_variant)
        add_image(product, new_variant)
        new_variant.save!
        add_stock(new_variant, product)
      else
        new_product = Spree::Product.create!(name: product.name, description: product.description,
                                             meta_keywords: "#{product.slug}, #{product.name}",
                                             meta_description: product.meta_description, meta_title: product.meta_title,
                                             price: product.price, cost_price: product.cost_price,
                                             shipping_category: Spree::ShippingCategory.find_or_create_by!(name: product.shipping),
                                             slug: product.slug.downcase)

        new_product.stores << Spree::Store.find_by_code(product.store) if product.store 
       # add_translations(new_product, product)
        add_product_property(product, new_product)
        add_taxons_and_taxonomies(product, new_product)
        if product.qty
          new_variant = Spree::Variant.new(clean_variant(product), price: product.price)
          new_variant.product = new_product
          add_option_type(product, new_variant)
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
        update_product.update_attributes(clean_product(product))
        if product.update_slug.present?
          update_product.update_attributes(slug: product.update_slug)
        end 
        #add_translations(update_product, product)
        add_taxons_and_taxonomies(product, update_product)
        add_product_property(product, update_product)
        update_product.save!
      else
        update_variant = Spree::Variant.find_by(sku: product.sku )
        update_variant.update_attributes(clean_variant(product))
        update_variant.price = product.price if product.price.present?
        add_option_type(product, update_variant)
        add_image(product, update_variant)
        update_variant.save!
        add_stock(update_variant, product)
      end
    end
  end

  private

  def add_taxons_and_taxonomies(product, new_product)
    taxons = product.instance_values.select { |key, value| key.match(/taxon_/) && value.present? }
    taxonomies = product.instance_values.select { |key, value| key.match(/taxonomy_/) && value.present? }
    if taxons.present? && taxonomies.present?
      taxons_and_taxonomies = Hash[taxonomies.values.zip taxons.values]
      taxons_and_taxonomies.each do |taxonomy_value, taxon_value|
        taxonomy = find_taxonomy(taxonomy_value.capitalize)
        taxon = find_taxon(taxon_value.capitalize)
        taxonomy.taxons << taxon if !taxonomy.taxons.include? taxon
        taxon.products << new_product 
      end
    end
  end

  def add_option_type(product, new_variant)
    option_types = product.instance_values.select { |key, value| key.match(/option_type_/) && value.present? }
    option_values = product.instance_values.select {|key, value| key.match(/option_value_/)  && value.present? }
    if option_types.present? && option_values.present?
      option_values_and_types = Hash[option_types.values.zip option_values.values]
      option_values_and_types.map do |option, value| 
        option_type = find_option_type(option.capitalize)
        option_value = Spree::OptionValue.find_or_create_by!(option_type: option_type, name: value, presentation: value)
        new_variant.product.option_types << option_type if !new_variant.product.option_types.include?(option_type)
        new_variant.option_values << option_value
      end
    end
  end

  def add_product_property(product, new_product)
    property_types  = product.instance_values.select { |key, value| key.match(/property_type_/) && value.present? }
    property_values  = product.instance_values.select { |key, value| key.match(/property_value_/) && value.present? }

    if property_types.present? && property_values.present?
      property_values_and_types = Hash[property_types.values.zip property_values.values]
      property_values_and_types.map do |property, value|
        property = find_property(property.capitalize)
        Spree::ProductProperty.find_or_create_by(property: property, value: value.to_yaml, product: new_product) if !new_product.properties.include?(property)
      end
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

  def clean_variant(variant)
    variant.instance_values.symbolize_keys.reject {|key, value| !Spree::Variant.attribute_method?(key) || value.nil? }
  end

  def clean_product(product)
    product.instance_values.symbolize_keys.reject {|key, value| !Spree::Product.attribute_method?(key) || value.nil? }
  end

  def find_property(property)
    Spree::Property.find_or_create_by(name: property, presentation: property)
  end

  def find_option_type(option)
    Spree::OptionType.find_or_create_by(name: option, presentation: option)
  end
  
  def find_taxon(taxon)
    Spree::Taxon.find_or_create_by(name: taxon)
  end

  def find_taxonomy(taxonomy)
    Spree::Taxonomy.find_or_create_by(name: taxonomy)
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
