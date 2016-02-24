require 'spec_helper'

describe Spree::ProductImport, type: :model do 
    let!(:shipping) {create(:shipping_category, name: "Shipping")}
    let!(:product_import)  { create(:product_import)  }
    #let!(:product_import_translate)  { create(:product_translations_import) }
    let!(:import_products_and_variants) { create(:product_import_variant) }
    let!(:stock_location) {create(:stock_location) }

#    it { should have_attached_file(:csv_import) }

   context 'Uploading products' do 
     it 'successfully uploads Product data' do 
       product_import.add_products!
       expect(Spree::Product.count).to eq 1 
     end

     #it 'successfully adds Transaltiosn to a Product' do 
       #product_import_translate.add_products!
       #expect(Spree::Product::Translation.count).to eq 2 

       #I18n.locale = :cn
         #product = Spree::Product.first
         #expect(product.name).to eq "你好"
       #I18n.locale = :en
     #end
     
    context "testing product variants" do 
       before(:each) do 
         import_products_and_variants.add_products!
         @product = Spree::Product.first
         @variant = Spree::Variant.last
       end 

       it "creates a variant for a product if the slugs match" do 
         expect(@product.variants.count).to eq 1
         expect(@product.properties.count).to eq 1 
         expect(@product.product_properties.count).to eq 1 
         expect(@variant.total_on_hand).to eq 24
         expect(@variant.option_values.count).to eq 2
       end 

       it "adds the correct dimensions" do  
         expect(@variant.height).to eq 22 
         expect(@variant.width).to eq 8 
         expect(@variant.depth).to eq 9
         expect(@variant.weight).to eq 10
       end 
     end 
     
     it "will not create a variant if stock_ites_count is empty" do 
       empty_stock_product = create(:product_import_empty_stock) 
       empty_stock_product.add_products!
       product = Spree::Product.first
       expect(product.variants.count).to eq 0 
     end 

     it "creates a variant for a product if stock_items_count is present" do 
       product_import.add_products!
       product = Spree::Product.first
       expect(product.variants.count).to eq 1
       expect(product.variants.first.total_on_hand).to eq 39
     end 

     it "Adds an option type to a product" do 
       product_import.add_products!
       product = Spree::Product.first
       expect(Spree::OptionType.count).to eq 1
     end 
   end 
    
    context "Adds Products to correct Taxons" do
      it "succesfullys adds a current product taxon" do
         taxon_youxi = create(:taxon, name: "Youxi")
         taxon_home = create(:taxon, name: "Home and Living")
         product_import.add_products!
         product = Spree::Product.first
         expect(product.taxons.count).to eq 3
       end

       it "does not add the same taxon twice" do
         taxon_home = create(:taxon, name: "Home and Living")
         product = create(:product, name: "Lightbulb Photo Holder")

         product.taxons << taxon_home
         product_import.add_products!
         product.reload
         expect(product.taxons.count).to eq 1
         expect(product.taxons).to include taxon_home
       end
    end

    context "Add Properties to products" do 
       it "succesfullys adds a current product property" do 
         material = create(:property, name: "Material", presentation: "Material")
         product_import.add_products!
         product = Spree::Product.first
         expect(product.properties.count).to eq 1
         expect(product.properties).to include material
       end 
     
       it "it successfully creates a property if it can not find it by the name" do 
         product_import.add_products!
         expect(Spree::ProductProperty.count).to eq 1 
       end 

       it "It doesn't add a property if it already exists in the product" do 
         product = create(:product, name: "Lightbulb Photo Holder")
         material = create(:property, name: "Material", presentation: "Material")
         product.properties << material
         product_import.add_products!
         expect(product.properties.count).to eq 1 
       end 
    end 

    context "Add Option Types to products" do 
      it "succesfullys adds a current product option_type when it has variants" do 
         import_products_and_variants.add_products!
         product = Spree::Product.first
         expect(product.option_types.count).to eq 2
      end 
    end 

    describe '.update_products' do 
      let!(:product) {create(:product, slug: "youxi-holder-lightbulb", price: 30)}
      let!(:update_product_import) {create(:update_product_import) }
      let!(:update_no_price_import) {create(:update_no_price_import) }
      let!(:variant) { create(:variant, product: product, sku: "test-sku-1", stock_items_count: 2)}
      let!(:update_variant_import) {create(:update_variant_import) } 

      context 'Update products' do 
        it "allows a user to update a product" do 
          update_product_import.update_products!
          product.reload
          expect(product.price).to be_within(1).of(15) 
        end 
        
        it "does not updates price if price is empty" do 
          update_no_price_import.update_products!
          product.reload
          expect(product.price).to eq 30 
          expect(product.name).to eq "Lightbulb Photo Holder"
        end 

        it "inserts an updated product into a taxon" do
          taxonomy_materials = create(:taxonomy, name: 'Materials')
          taxonomy_supplies = create(:taxonomy, name: 'Supplies')
          taxon_home = create(:taxon, name: "Home and Living", parent_id: taxonomy_supplies.id)
          taxon_youxi = create(:taxon, name: "Youxi", parent_id: taxonomy_materials.id)
          update_product_import.update_products!
          product.reload
          expect(product.taxons.count).to eq 3
        end
      
        it "adds a property to and updated product" do
          material = create(:property, name: "Material", presentation: "Material")
          update_product_import.update_products!
          expect(product.properties.count).to eq 1
          expect(product.properties).to include material
        end
      
        it "doesnt add a property to updated products if the property already exists" do
          material = create(:property, name: "Material", presentation: "Material")
          product.properties << material
          update_product_import.update_products!
          product.reload
          expect(Spree::Property.count).to eq 1
        end
      
        it "adds a new product property to update products" do
          update_product_import.update_products!
          product.reload
          expect(product.product_properties.count).to eq 1
        end
      
        it "doesnt add a value to updated products if the value already exists" do
          material = create(:property, name: "Material", presentation: "Material")
          product_property = create(:product_property, property: material, product: product, value: "Natural Reclaimed Wood")
          update_product_import.update_products!
          product.reload
          expect(product.product_properties.count).to eq 1
         end
       end
      
       context "update product variants" do
         it "updates the variants stock" do
           update_variant_import.update_products!
           stock_item = Spree::StockItem.find_by(variant_id: variant.id)
           expect(stock_item.count_on_hand).to eq 24
         end
      end
    end 
 end


