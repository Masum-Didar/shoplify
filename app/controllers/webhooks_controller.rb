class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    endpoint_secret = 'whsec_9c8c22139163aa3e06bc32ed5ef33d44cd33d1fe7cf011737d94e2a0347eb221'


    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      puts "Signature error"
      p e
      return
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      @product = Product.find_by(price: session.amount_total)
      @product.increment!(:sales_count)
    end

    render json: { message: 'success' }
  end
end