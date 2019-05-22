class ManageOrdersController < ApplicationController
  include ApplicationHelper
  before_action :set_uptoken, only: [:edit_deliver, :update_deliver]
  before_action :set_order, only: [:show, :deliver, :edit_payment, :update_payment, :deliver_message, :send_message, :payment_logs, :edit_deliver, :update_deliver, :deliver_logs ]

  def index
    @orders = Order.search_conn(params).order('applied_at desc').page(params[:page]).per(Settings.per_page)
    response do |format|
      format.js
    end
  end

  def deliver
    @orders = Order.search_conn(params).order('updated_at desc').page(params[:page]).per(Settings.per_page)
    if @order.deliver_file.present?
      @order.deliver_file.update file_name: params[:file_name], path: params[:path]
    else
      @order.create_deliver_file file_name: params[:file_name], path: params[:path]
    end
    render template: 'manage_orders/index'
  end

  def show
    respond_to do |format|
      format.xls do
        headers["Content-Disposition"] = "attachment; filename=\"订单-#{@order.no}.xls\""
      end
      format.html do
        render layout: false
      end
    end

  end

  def edit_payment
    @payment_log = @order.payment_logs.new
    render layout: false
  end

  def update_payment
    @payment_log = @order.payment_logs.new
    @flag = @payment_log.update amount: params[:payment_log][:amount], payment_at: params[:payment_log][:payment_at], user: current_user
  end

  def edit_deliver
    @deliver_log = @order.deliver_logs.new
    render layout: false
  end

  def deliver_logs
    @deliver_logs = @order.deliver_logs.order('deliver_logs.deliver_at desc')
    render layout: false
  end

  def update_deliver
    @deliver_log = @order.deliver_logs.new
    @deliver_log.build_deliver_file path: params[:path], file_name: params[:file_name] if params[:path].present?
    @flag = @deliver_log.update amount: params[:amount], deliver_at: params[:deliver_at], user: current_user
  end

  def payment_logs
    @payment_logs = @order.payment_logs.order('payment_logs.payment_at desc')
    render layout: false
  end

  def deliver_message
    @deliver = @order.delivers.new
    render layout: false
  end

  def send_message
    @deliver = @order.delivers.new
    @flag = @deliver.update deliver_permit
  end

  private
  def set_uptoken
    @uptoken = uptoken
  end

  def set_order
    @order = Order.find_by id: params[:id]
    redirect_to manage_orders_path unless @order.present?
  end

  def deliver_permit
    params.require(:deliver).permit :phone_to, :name, :phone, :number
  end

end
