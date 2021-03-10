# frozen_string_literal: true

# Represents a line item with a link to a Product
class Item
  attr_reader :product_code
  attr_accessor :reduced_price

  def initialize(product_code:)
    @product_code = product_code
    @product = Product.find_by(code: product_code)
    @reduced_price = nil
  end

  # The price for the item will be a reduced price if set are the price of the product
  def price
    reduced_price || product.price
  end

  private

  attr_reader :product
end
