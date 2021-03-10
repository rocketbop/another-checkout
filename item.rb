class Item
  def initialize(product_code:)
    @product = Product.find_by(code: product_code)
  end

  def price
    @product.price
  end
end
