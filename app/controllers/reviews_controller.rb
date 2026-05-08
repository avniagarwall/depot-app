class ReviewsController < ApplicationController
  before_action :set_product
  before_action :set_review, only: [:show, :destroy]

  # READ - all reviews for a product
  def index
    @reviews = @product.reviews.all
  end

  # READ - single review
  def show
  end

  # CREATE - form
  def new
    @review = Review.new
  end

  # CREATE - save
  def create
    @review = @product.reviews.new(review_params)
    if @review.save
      redirect_to product_reviews_path(@product), notice: "Review added!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE
  def destroy
    @review.destroy
    redirect_to product_reviews_path(@product), notice: "Review deleted."
  end

  private

    def set_product
      @product = Product.find(params[:product_id])
    end

    def set_review
      @review = @product.reviews.find(params[:id])
    end

    def review_params
      params.require(:review).permit(:reviewer_name, :rating, :body)
    end
end