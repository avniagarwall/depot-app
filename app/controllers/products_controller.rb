class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
   @products = Product.includes(:category, :sub_category).all

    respond_to do |format|
      format.html
      format.json do
        render json: @products.map { |p|
          {
            name: p.title,
            category_name: p.category&.name || p.sub_category&.name || "Uncategorized"
          }
        }
      end
    end
  end

  # GET /products/1 or /products/1.json
  def show
  end

  def new
    @product = Product.new
    @category_options = category_options_for_select
  end

  def edit
    @category_options = category_options_for_select
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)
    assign_categorization

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        @category_options = category_options_for_select
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    assign_categorization

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @product }
        @product.broadcast_replace_later_to "store/products", partial: "store/product"
      else
        @category_options = category_options_for_select
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # 5 - adding new parameters in controller
  def product_params
    params.expect(product: [ :title, :description, :image, :price, :enabled, :discount_price, :permalink ])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [ :title, :description, :price, :discount_price, :permalink, :enabled, images: [] ])
    end

    def assign_categorization
      val  = params.dig(:product, :categorization_value)   # e.g. "Category_3"
      return if val.blank?

      type, id = val.split("_")
      if type == "Category"
        @product.category     = Category.find_by(id: id)
        @product.sub_category = nil
      elsif type == "SubCategory"
        @product.sub_category = SubCategory.find_by(id: id)
        @product.category     = nil
      end
    end

    def category_options_for_select
      options = []
      Category.includes(:sub_categories).order(:name).each do |cat|
        options << [cat.name, "Category_#{cat.id}"]
        cat.sub_categories.each do |sub|
          options << ["-- #{sub.name}", "SubCategory_#{sub.id}"]
        end
      end
      options
    end
end
