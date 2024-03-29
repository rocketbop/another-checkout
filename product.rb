# frozen_string_literal: true

# The product holds information on global price as well as name etc
class Product
  attr_reader :code, :name, :price

  def initialize(code, name, price)
    @code = code
    @name = name
    @price = price
  end

  # @return [Product] instance of the inserted product
  def self.insert(code:, name:, price:)
    db = SQLite3::Database.new "test.db"
    db.execute(
      "INSERT INTO products (code, name, price) VALUES (?, ?, ?)",
      [code, name, price])

    find_by(code: code)
  end

  # @return [Product] instance of the inserted product
  def self.find_by(code:)
    db = SQLite3::Database.new "test.db"
    row = db.execute( "select code, name, price from products where products.code=?", code).first
    new(*row)
  end
end
