require_relative './../checkout'
require_relative './../product'
require_relative './../item'
require_relative './../spend_amount_get_percent_discount'
require_relative './../buy_2_get_reduction_discount'
require 'sqlite3'

RSpec.describe Checkout do
  subject(:checkout) { described_class.new(promotional_rules) }

  let(:promotional_rules) { [] }

  around do |example|
    prepare_and_cleanup_db(example)
  end

  let(:product1) { Product.insert(code: "001", name: "Lavender heart", price: 9.25) }
  let(:product2) { Product.insert(code: "002", name: "Personalised cufflinks", price: 45.0) }
  let(:product3) { Product.insert(code: "003", name: "Kids T-shirt", price: 19.95) }

  let(:item1) { Item.new(product_code: product1.code) }
  let(:item2) { Item.new(product_code: product2.code) }
  let(:item3) { Item.new(product_code: product3.code) }

  describe "#scan" do
    subject(:scan) { checkout.scan(item1) }

    it 'adds the item and updates the total' do
      expect{ scan }.to change{ checkout.total }.from("£0.00").to("£9.25")
    end
  end

  describe "#total" do
    subject(:total) { checkout.total }

    it "is zero" do
      expect(total).to eq("£0.00")
    end

    context "when an item is scanned" do
      before do
        checkout.scan(item1)
      end

      it "returns the cost of the item" do
        expect(total).to eq("£9.25")
      end
    end

    context "when an item is scanned twice" do
      before do
        checkout.scan(item1)
        checkout.scan(item1)
      end

      it "returns the item's price by the quantity" do
        expect(total).to eq("£18.50")
      end
    end

    context "when SpendOver60Get10PercentOff and Buy2GetReduction discounts applies" do
      let(:promotional_rules) {
        [
          SpendAmountGetPercentDiscount.new(amount: 60, percent_discount: 10),
          Buy2GetReductionDiscount.new(product_code: product1.code, reduced_price: 8.5)
        ]
      }

      context "when the subtotal is below 60" do
        before do
          checkout.scan(item1)
        end

        it "applies no discount" do
          expect(total).to eq("£9.25")
        end
      end

      context "when the subtotal goes over 60" do
        before do
          checkout.scan(item1)
          checkout.scan(item2)
          checkout.scan(item3)
        end

        it "subtracts 10%" do
          expect(total).to eq("£66.78")
        end
      end

      context "when there are items qualifying for a Buy2GetReduction discount" do
        before do
          checkout.scan(item1)
          checkout.scan(item3)
          checkout.scan(item1)
        end

        it "reduces the price for each qualifying item" do
          expect(total).to eq("£36.95")
        end
      end

      context "when there are items qualifying for Buy2GetReductionDiscount \"
        and SpendOver60Get10PercentOff discounts" do
        before do
          checkout.scan(item1)
          checkout.scan(item2)
          checkout.scan(item1)
          checkout.scan(item3)
        end

        it "applies both discounts" do
          expect(total).to eq("£73.76")
        end
      end
    end
  end

  # Add a simple DB layer for our products
  def prepare_and_cleanup_db(example)
    db = SQLite3::Database.new "test.db"

    db.execute <<~SQL
      create table products (
        name varchar(30),
        code varchar(30),
        price numeric
      );
    SQL

    example.run

    db.execute <<~SQL
      drop table products
    SQL
  end
end


