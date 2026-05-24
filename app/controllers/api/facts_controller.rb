class Api::FactsController < ApplicationController
  respond_to :json

  def random
    fact = Fact.order(Arel.sql("RANDOM()")).limit(1).first
    if fact
      render json: { id: fact.id, body: fact.body }
    else
      render json: { error: "no_facts_available", message: "No fun facts are currently available." },
             status: :not_found
    end
  end

  def next
    client_id = params[:client_id]
    if client_id.blank?
      render json: { error: "missing_client_id", message: "client_id is required." },
             status: :bad_request
      return
    end

    client = Client.find_by(client_identifier: client_id)
    unless client
      render json: { error: "unknown_client", message: "No eligible client matches the provided client_id." },
             status: :not_found
      return
    end

    fact = ClientNextFactResolver.new(client).call
    if fact
      render json: { id: fact.id, body: fact.body }
    else
      render json: { error: "no_facts_available", message: "No fun facts are currently available." },
             status: :not_found
    end
  end
end
