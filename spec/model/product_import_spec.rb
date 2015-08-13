require 'spec_helper'

describe Spree::ProductImport do 
 it { should have_attached_file(:csv_import) }
end 
