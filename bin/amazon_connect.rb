require 'json'
require './lib/amazon_connecter'

class AmazonConnect

  product_info = AmazonConnecter.new.search(ARGV[0], 140)
  p product_info

end