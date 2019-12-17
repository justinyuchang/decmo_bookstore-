require 'rails_helper'
 
RSpec.describe Cart, type: :model do

  let(:cart) { Cart.new }

  context "進階功能" do
    it "可以將購物車內容轉換成 Hash 並存到 Session 裡" do
      # cart = Cart.new
      book1 = create(:book)
      book2 = create(:book)

      3.times { cart.add_item(book1.id)}
      2.times { cart.add_item(book2.id)}

      expect(cart.serialize).to eq cart_hash
    end

    it "也可以存放在Session內容 (Hash格式)，還原成購物車內容" do
      cart = Cart.from_hash(cart_hash)

      expect(cart.items.count).to be 2 
      expect(cart.items.first.quantity).to be 3 
    end  
  end  

  context "基本功能" do 
    it "把商品丟到購物車，購物車就有東西" do 
      # cart = Cart.new 
      cart.add_item(1)
      expect(cart.empty?).to be false  # expect(cart).not_to be_empty
    end

    it "加了相同商品，項目不會增加，商品數量會改變" do
      # cart = Cart.new 
      3.times { cart.add_item(1) }
      2.times { cart.add_item(2) }
      
      expect(cart.items.count).to be 2
      expect(cart.items.first.quantity).to be 3
    end

    it "商品可以放到購物車，可以再拿出來" do
      # cart = Cart.new 
      book = create(:book)

      cart.add_item(book.id)
      expect(cart.items.first.product).to be_a Book
    end

    it "可以計算整台購物車總額" do
      # AAA
      # Arrange
      cart = Cart.new

      book1 = create(:book, sell_price: 50)
      book2 = create(:book, sell_price: 100)

      # Act
      3.times { cart.add_item(book1.id) }
      2.times { cart.add_item(book2.id) }

      # Assert
      expect(cart.total_price).to eq 350
    end
  end

    private 
    def cart_hash
      {
        "items" => [
          {"product_id" => 1 , "quantity" => 3}, 
          {"product_id" => 2 , "quantity" => 2}
        ]
      }
    end
  end

