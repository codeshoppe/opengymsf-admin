class MembershipsController < ApplicationController
  before_action :authenticate_user!

  before_action :skip_authorization
  before_action :skip_policy_scope

  def new
    if policy(:membership).new?
      @client_token = Braintree::ClientToken.generate(customer_id: braintree_customer.customer_id)
    else
      redirect_to membership_path, notice: "You already have a membership."
    end
  end

  def create
    authorize(:membership, :create?)
    payment_method = params[:payment_method_nonce]
    success = PaymentService::Subscription.create(braintree_customer.customer_id, payment_method)

    if !!success
      redirect_to membership_path, notice: "Success!"
    else
      flash[:error] = "Could not create subscription, please contact the admin."
      render :new
    end
  end

  private
  def braintree_customer
    current_user.braintree_customer
  end

end
