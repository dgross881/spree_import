require 'date'

module Spree
  class ImportProduct
    attr_accessor :name, :description, :slug, :meta_description,
                  :meta_keywords, :meta_keywords, :promotionable,
                  :meta_title, :price, :vendor, :option1, :option2, 
                  :weight, :quantity, :tags, :type, :option_value,
                  :taxons, :option_type

    def initialize(csv_row)
       @name = csv_row[:name]
       @description = csv_row[:description]
       @slug =  csv_row[:slug]
       @meta_description = csv_row[:meta_description]
       @meta_keywords = csv_row[:meta_keywords] 
       @promotionable =  csv_row[:promotionable]
       @meta_title = csv_row[:meta_title] 
       @price = csv_row[:price].to_i
       @vendor = csv_row[:vendor]
       @tags = csv_row[:tags]
       @type = csv_row[:type]
       @option_type = csv_row[:option_type]
       @taxons = csv_row[:taxons]
    end
  end
end 
