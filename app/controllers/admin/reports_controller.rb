class Admin::ReportsController < Admin::BaseController
  def index
    @from = params[:from].present? ? Date.parse(params[:from]) : 5.days.ago.to_date
    @to   = params[:to].present?   ? Date.parse(params[:to])   : Date.today

    @orders = Order.includes(line_items: :product)
                   .where(created_at: @from.beginning_of_day..@to.end_of_day)
                   .order(created_at: :desc)
  end
end