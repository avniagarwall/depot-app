class OrderMailer < ApplicationMailer
  default from: "Sam Ruby <depot@example.com>"

  def received(order)
    @order      = order
    @user       = order.user
    @line_items = order.line_items.includes(:product)

    # Attach extra images (2nd, 3rd) of each product as email attachments
    @line_items.each do |item|
      next unless item.product.images.attached? && item.product.images.count > 1

      item.product.images.drop(1).each_with_index do |img, i|
        attachments["#{item.product.title}-image-#{i + 2}.jpg"] = img.download
      end
    end

    I18n.with_locale(@user&.locale || :en) do
      mail(
        to:      order.email,
        subject: I18n.t('mailer.order_mailer.subject', id: @order.id)
      )
    end
  end

  def shipped(order)
    @order = order
    mail to: order.email, subject: "Pragmatic Store Order Shipped"
  end

  # ADD: consolidated summary email
  def consolidated_orders(user)
    @user   = user
    @orders = user.orders.includes(line_items: :product)

    I18n.with_locale(@user.locale) do
      mail(
        to:      @user.email_address,
        subject: I18n.t('mailer.consolidated.subject')
      )
    end
  end

  private

  # ADD: injects process id into every email header
  def headers_for(part_type, headers)
    super.merge('X-SYSTEM-PROCESS-ID' => Process.pid.to_s)
  end
end