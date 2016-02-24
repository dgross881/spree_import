module CsvHelpers 
  module Feature
    def successfull_import
      StringIO.new(<<-EOS)
        slug, name, description, price, tags, meta_title, meta_description, meta_keywords, vendor, option_type, type, taxons
quillingcard-greetingcard-small-love, Daves Quilling Cards,  Daves Quilling Cards Rooted in Vietnam each artist is assigned to a single design, 24.00, Small Love Cards from Quilling Card, quilling-card, recycled quilling cards, cards paper, the squirrelz, Graphic, Greeting Cart, The Taxon
      EOS
    end 
  end 
end 
