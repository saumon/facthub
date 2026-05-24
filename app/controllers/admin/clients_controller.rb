class Admin::ClientsController < Admin::BaseController
  before_action :set_client, only: %i[show reset destroy]

  def index
    @clients = Client.order(:created_at)
    @facts_count = Fact.count
  end

  def show
    @facts_count = Fact.count
    @last_fact = Fact.find_by(id: @client.last_fact_id) if @client.last_fact_id.present?
    @next_fact =
      if @client.last_fact_id.present?
        Fact.where("id > ?", @client.last_fact_id).order(:id).first || Fact.order(:id).first
      else
        Fact.order(:id).first
      end
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new
    if @client.save
      redirect_to admin_client_path(@client), notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def reset
    @client.reset_progression!
    redirect_back fallback_location: admin_client_path(@client), notice: "Client progression was reset."
  end

  def destroy
    @client.destroy
    redirect_to admin_clients_path, notice: "Client was successfully deleted."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end
end
