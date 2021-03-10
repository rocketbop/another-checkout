require "sqlite3"

# Checkout handles scanning, and keeps a running total of line items, as well
# as a total value that is updated whenever an item is scanned
class Checkout
  attr_reader :subtotal, :non_global_rules, :global_rules

  def initialize(promotional_rules = [])
    @promotional_rules = promotional_rules
    @non_global_rules = promotional_rules.reject(&:global)
    @global_rules = promotional_rules.select(&:global)
    @subtotal = 0.0
    @items = []
  end

  # @param [Item] the line item for a given Product
  def scan(item)
    items << item
    apply_item_level_rules(item)
    update_total
  end

  def total
    format("£%.2f", subtotal)
  end

  private

  attr_reader :items, :promotional_rules
  attr_writer :subtotal

  def apply_item_level_rules(item)
    non_global_rules.reduce(item) do |item, rule|
      rule.apply_discount(items, item)
    end
  end

  def update_total
    self.subtotal = items.sum(&:price)
    self.subtotal = subtotal - global_discounts.sum
    subtotal
  end

  def global_discounts
    global_rules.map do |rule|
      rule.discount_for_items(items)
    end
  end
end

