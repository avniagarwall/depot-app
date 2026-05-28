class Admin::CategoriesController < Admin::BaseController
  def index
    @categories = Category.includes(:sub_categories, :products, sub_categories: :products)
                           .order(:name)
  end
end