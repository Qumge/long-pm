class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all.page(params[:page]).per(Settings.per_page)
  end

  def new
    @product = Product.new
    render layout: false
  end

  def create
    @product = Product.new product_permit
    @flag = @product.save
    @flag
  end

  def show

  end

  def destroy
    redirect_to products_path, notice: '删除成功' if @product.destroy
  end

  def edit
    render layout: false
  end

  def update
    @flag = @product.update product_permit
  end

  private
  def set_product
    @product = Product.find_by id: params[:id]
    redirect_to products_path, alert: '找不到数据' unless @product.present?
  end

  def product_permit
    params.require('product').permit(:no, :product_no, :unit, :reference_price, :name)
  end

end