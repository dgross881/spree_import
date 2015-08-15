FactoryGirl.define do
  factory :product_import, class: Spree::ProductImport do
    csv_import_file_name "product_import.csv" 
  end 


  def successful_import
    StringIO.new(<<-EOS)
      slug, quillingcard-greetingcard-small-love
      name, Daves Quilling Cards (Small)
      description, Rooted in Vietnam, each artist is assigned to a single design
      tags, Small Love Cards from Quilling Card at samle 
      price, 24 
      meta_title, The Squirrelz 
      meta_description, This is a great day 
      vendor, The Skulls 
      option_type, Graphic 
      type, Greeting Card
      taxon, The Taxon
    EOS
  end 
end
