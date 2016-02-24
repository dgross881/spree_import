require 'ffaker'
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :product_import, class: Spree::ProductImport do
    csv_import { fixture_file_upload('spec/fixtures/product_import.xlsx', 'application/excel') }
    preferred_add_products true 
  
  
    factory :product_translations_import  do 
      csv_import { fixture_file_upload('spec/fixtures/product_import_translate.xlsx', 'application/excel') }
      preferred_add_products true 
    end 
    
    factory :product_import_variant  do 
      csv_import { fixture_file_upload('spec/fixtures/product_import_variant.xlsx', 'application/excel') }
      preferred_add_products true 
    end 

    factory :product_import_empty_stock  do 
      csv_import { fixture_file_upload('spec/fixtures/product_import_empty_stock.xlsx', 'application/excel') }
      preferred_add_products true 

    end 

    factory :update_product_import do 
      csv_import { fixture_file_upload('spec/fixtures/product_import.xlsx', 'application/excel') }
      preferred_add_products true 
    end 

    factory :update_no_price_import do 
      csv_import { fixture_file_upload('spec/fixtures/product_import_no_price.xlsx', 'application/excel') }
      preferred_add_products true 
    end 
    
    factory :update_variant_import do 
      csv_import { fixture_file_upload('spec/fixtures/product_import_update_variant.xlsx', 'application/excel') }
      preferred_add_products true 
    end 
   end 
end
