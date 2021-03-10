# frozen_string_literal: true

# A discount rule that applies to the basket globally
# rather than on an individual item level
class SpendAmountGetPercentDiscount
  def initialize(amount:, percent_discount:)
    @amount = amount
    @percent_discount = percent_discount
  end

  def global
    true
  end

  # @param [Array<Item>]
  #
  # When the amount rule is met returns the total discount to be applied to the basket
  # @return [BigDecimal]
  def discount_for_items(items)
    items_subtotal = items.sum(&:price)
    if items_subtotal > 60
      items_subtotal * 0.1
    else
      0
    end
  end

  private

  attr_reader :amount, :percent_discount
end
