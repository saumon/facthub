class ClientNextFactResolver
  def initialize(client)
    @client = client
  end

  # Returns the next Fact for the client (advancing the cursor atomically),
  # or nil if no facts are available.
  def call
    @client.with_lock do
      fact = next_fact
      @client.update_columns(last_fact_id: fact.id) if fact
      fact
    end
  end

  private

  def next_fact
    if @client.last_fact_id.present?
      # Attempt to find the next fact strictly after the stored cursor
      fact = Fact.where("id > ?", @client.last_fact_id).order(:id).first
    end

    # Wrap around (or first call): start from the lowest available fact id
    fact ||= Fact.order(:id).first
    fact
  end
end
