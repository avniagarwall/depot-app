class CategoriesController < ApplicationController
  def index
    @categories = Category.includes(:sub_categories).order(:name)
  end

  def show
  end

  def new
  end

  def edit
  end
end
