class ReviewsController < ApplicationController
  layout "reviews"  # ← Nested layout for all review actions

  before_action :set_product
  before_action :set_review, only: [:show, :destroy]

  def index
    @reviews = @product.reviews.order(created_at: :desc)
    # Convention over config — auto-renders views/reviews/index.html.erb
  end

  def show
  end

  def new
    @review = Review.new
  end

  def create
    @review = @product.reviews.new(review_params)
    if @review.save
      # redirect_to → new HTTP request, prevents form resubmission on refresh
      redirect_to product_reviews_path(@product), notice: "Review added!"
    else
      # render :new → stays in same request, keeps @review with its errors
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    # redirect_back → returns to wherever user came from
    redirect_back fallback_location: product_reviews_path(@product),
                  notice: "Review deleted."
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
