require "sqlite3"

class Checkout
  attr_reader :subtotal

  def initialize(promotional_rules)
    @subtotal = 0.0
    @items = []
  end

  def scan(item)
    items << item
    update_total

  end

  def total
    format("£%.2f", subtotal)
  end

  private

  attr_reader :items
  attr_writer :subtotal

  def update_total
    self.subtotal = items.sum(&:price)
    subtotal
  end
end

