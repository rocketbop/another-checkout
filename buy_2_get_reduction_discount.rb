# frozen_string_literal: true

# A discount rule that applies to individual items
class Buy2GetReductionDiscount
  def initialize(product_code:, reduced_price:)
    @product_code = product_code
    @reduced_price = reduced_price
  end

  def global
    false
  end

  # @param [Array<Item>]
  # @param [Item]
  #
  # Sets the reduced price on the item if the qualifying rules are met
  # @return [Item]
  def apply_discount(items, item)
    qualifying_items = items.select { _1.product_code == product_code }
    if qualifying_items.size >= 2
      qualifying_items.map { _1.reduced_price = reduced_price }
    end
    item
  end

  private

  attr_reader :product_code, :reduced_price
end
