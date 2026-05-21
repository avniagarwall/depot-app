class Admin::CategoriesController < Admin::BaseController
  def index
    @categories = Category.includes(:sub_categories, :products, sub_categories: :products)
                           .order(:name)
  end

  def show
    @category = Category.includes(:sub_categories, :products, sub_categories: :products)
                        .find(params[:id])
    @products = @category.all_products
  end
end