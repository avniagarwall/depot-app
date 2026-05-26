require "pago"

class Order < ApplicationRecord
  enum :pay_type, {
    "Check"          => 0,
    "Credit card"    => 1,
    "Purchase order" => 2
  }
  belongs_to :user, optional: true
  has_many :line_items, dependent: :destroy
  has_many :support_requests, dependent: :nullify

  # 2. Add another scope in order which accept two dates and return orders placed between
  # those dates
  # ○ Order.by_date(from, to)
  # ○ Order.by_date : without arguments, should return order for the current day
  # ○ user.orders.by_date should work and it should return orders placed by user
  # between given dates. Check the query difference in this one and the above one
  scope :by_date, ->(from = Date.today.beginning_of_day, to = Date.today.end_of_day) {
    where(created_at: from..to)
  }

  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: pay_types.keys

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  def charge!(pay_type_params)
    payment_details = {}
    payment_method = nil

    case pay_type
    when "Check"
      payment_method = :check
      payment_details[:routing] = pay_type_params[:routing_number]
      payment_details[:account] = pay_type_params[:account_number]
    when "Credit card"
      payment_method = :credit_card
      month, year = pay_type_params[:expiration_date].split(//)
      payment_details[:cc_num] = pay_type_params[:credit_card_number]
      payment_details[:expiration_month] = month
      payment_details[:expiration_year] = year
    when "Purchase order"
      payment_method = :po
      payment_details[:po_num] = pay_type_params[:po_number]
    end

    payment_result = Pago.make_payment(
      order_id: id,
      payment_method: payment_method,
      payment_details: payment_details
    )

    if payment_result.succeeded?
      OrderMailer.received(self).deliver_later
    else
      raise payment_result.error
    end
  end
end
