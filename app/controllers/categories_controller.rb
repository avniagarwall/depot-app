class CategoriesController < ApplicationController
  def index
    @categories = Category.root.with_subs.order(:name)
  end

  def show
  end
end
