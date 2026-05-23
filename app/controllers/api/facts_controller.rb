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
end
