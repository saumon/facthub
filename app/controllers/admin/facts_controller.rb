class Admin::FactsController < Admin::BaseController
  before_action :set_fact, only: %i[edit update destroy]

  def index
    @facts = Fact.order(:created_at)
  end

  def new
    @fact = Fact.new
  end

  def create
    @fact = Fact.new(fact_params)
    if @fact.save
      redirect_to admin_facts_path, notice: "Fact was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @fact.update(fact_params)
      redirect_to admin_facts_path, notice: "Fact was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fact.destroy
    redirect_to admin_facts_path, notice: "Fact was successfully deleted."
  end

  private

  def set_fact
    @fact = Fact.find(params[:id])
  end

  def fact_params
    params.expect(fact: [ :body ])
  end
end
