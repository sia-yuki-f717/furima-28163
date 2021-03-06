class CustomersController < ApplicationController
  before_action :set_item, only: [:index, :create]
  before_action :authenticate_user!, only: :index

  def index
    @customer_address = CustomerAddress.new
    if user_signed_in? && current_user.id == @item.user.id || @item.customer.present?
      redirect_to root_path
    end
  end

  def create
    @customer_address = CustomerAddress.new(customer_params)
    if @customer_address.valid?
      pay_item
    @customer_address.save
    redirect_to root_path
    else
    render :index
    end
  end

  private

  def customer_params
    params.require(:customer_address).permit(:postal_code, :prefecture_id, :city, :house_number, :building_name, :phone_number, :customer_id).merge(user_id: current_user.id, item_id: params[:item_id], token: params[:token] )
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def pay_item
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    Payjp::Charge.create(
      amount: @item.price,
      card: customer_params[:token],
      currency: 'jpy'
    )
  end

end
