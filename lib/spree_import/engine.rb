module SpreeImport
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_import'

    config.autoload_paths += %W(#{config.root}/lib)

    config.generators do |g|
      g.test_framework :rspec
    end
    
   #initializer :append_migrations do |app|
      #unless app.root.to_s.match root.to_s
        #config.paths["db/migrate"].expanded.each do |expanded_path|
          #app.config.paths["db/migrate"] << expanded_path
        #end
      #end 
    #end 

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

  end
end
