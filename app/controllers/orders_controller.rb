class OrdersController < ApplicationController
  before_action :authenticate_user!

  layout 'book'

  def index
    @orders = current_user.orders.order(id: :desc) 
  end 

  def create
    @order = current_user.orders.build(order_params)

    current_cart.items.each do |item|
      @order.order_items.build(book: item.product, 
                               quantity: item.quantity,
                               sell_price: item.product.sell_price) 
    end 

    if @order.save 
      # clear cart
      session['cart1234'] = nil
      redirect_to pay_order_path(@order), notice: 'Order is placed.'
    else
      render 'carts/checkout', notice: 'Error' 
    end
  end


  def pay
    gateway = Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: ENV['braintree_merchant_id'],
      public_key: ENV['braintree_public_key'],
      private_key: ENV['braintree_private_key']
      )

    @token = gateway.client_token.generate
    @order = current_user.orders.find_by(num: params[:id])

  end

  def paid
    nonce = params[:nonce]
    order = current_user.orders.find_by(num: params[:id])

    result = gateway.transaction.sale(
      amount: total_price,
      payment_method_nonce: nonce,
      options: {
        submit_for_settlement: true
  }
)

    if result.success?
      order.pay?
      redirect_to orders_path, notice: 'Transaction success'
    else
      redirect_to orders_path, notice: 'Error occur during transaction' #{result.transaction.status}
    end
  end

  def cancel
    # order = Order.find(num: params[:id], current_user) 
    order = current_user.orders.find_by(num: params[:id])
    order.cancel! if order.may_cancel?
    # TODO: If the payment is paid -> refund
    redirect_to orders_path, notice: 'Order: #{order.num} is cancelled!!!!!'
  end 

  private 
  def order_params
    params.require(:order).permit(:recipient, :tel, :address, :note)
  end

  def gateway
    gateway = Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: ENV['braintree_merchant_id'],
      public_key: ENV['braintree_public_key'],
      private_key: ENV['braintree_private_key']
      )
  end
end
