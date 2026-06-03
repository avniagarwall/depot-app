class ProductsController < ApplicationController
  before_action :set_product,    only: %i[ show edit update destroy ]
  before_action :set_categories, only: %i[ new edit create update ]

  # GET /products or /products.json
  def index
    @products = Product.includes(:category, :images_attachments).all

    respond_to do |format|
      format.html
      format.json do
        render json: @products.map { |p|
          { name: p.title, category: p.category&.name }
        }
      end
    end
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: I18n.t("flash.product.created") }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      product_attrs = product_params
      product_attrs = product_attrs.except(:images) if product_attrs[:images].blank?

      if @product.update(product_attrs)
        @product.broadcast_replace_later_to "store/products", partial: "store/product"
        format.html { redirect_to @product, notice: I18n.t("flash.product.updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: I18n.t("flash.product.destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def set_product
      @product = Product.find(params.expect(:id))
    end

    def set_categories
      @categories = Category.includes(:sub_categories).order(:name)
    end

    def product_params
      params.expect(product: [ :title, :description, :price, :discount_price,
                                :permalink, :enabled, :category_id,
                                images: [] ])
    end
end