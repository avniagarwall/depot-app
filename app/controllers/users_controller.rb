class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy orders line_items ]

  rescue_from User::AdminDeletionError, with: :handle_admin_deletion

  layout "myorders", only: %i[ orders line_items ]

  # GET /users or /users.json
  def index
    @users = User.order(:name)
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @user.build_address
  end

  # GET /users/1/edit
  def edit
    @user.address || @user.build_address
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: I18n.t("flash.user.created", name: @user.name) }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: I18n.t("flash.user.updated", name: @user.name) }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: I18n.t("flash.user.destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  def orders
    @orders = @user.orders.includes(line_items: :product)
  end

  def line_items
    @line_items = @user.line_items
                    .includes(:product, :order)
                    .page(params[:page]).per(5)
  end

  private

    def set_user