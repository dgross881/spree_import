module Spree
  class ImportProduct
    attr_accessor :name, :weight, :weight_units, :description, :height, :width, :depth,
                  :qty, :price, :cost_price, :slug, :sku, :meta_description, :update_slug,
                  :meta_title, :cost_currency, :image_src, :image_alt, :store, :shipping 


    def initialize(args)
      @cost_currency = 'CNY'
      args.collect do |k,v|
        if k.include?('qty')
          instance_variable_set("@#{k}", remove_zeros(v.to_i)) unless v.nil?
        else 
          instance_variable_set("@#{k}", v.respond_to?(:strip) ? v.strip : v) unless v.nil?  
        end 
      end
    end 
    
    def remove_zeros(csv)
      csv.equal?(0) || csv.equal?(0.00) ? nil : csv 
    end 
  end
end 
