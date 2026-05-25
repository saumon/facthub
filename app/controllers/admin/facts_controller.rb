class Admin::FactsController < Admin::BaseController
  before_action :set_fact, only: %i[edit update destroy]

  FACTS_PER_PAGE = 10

  def index
    total_count = Fact.count
    @total_pages = [ (total_count.to_f / FACTS_PER_PAGE).ceil, 1 ].max

    if params[:page].present?
      page_num = params[:page].to_i
      if page_num < 1
        redirect_to admin_facts_path(page: 1) and return
      elsif page_num > @total_pages
        redirect_to admin_facts_path(page: @total_pages) and return
      end
      @current_page = page_num
    else
      @current_page = 1
    end

    @total_facts = total_count
    @facts = Fact.order(created_at: :asc, id: :asc)
                 .limit(FACTS_PER_PAGE)
                 .offset((@current_page - 1) * FACTS_PER_PAGE)
  end

  def new
    @fact = Fact.new
    @current_page = params[:page].present? ? params[:page].to_i : 1
  end

  def create
    @fact = Fact.new(fact_params)
    if @fact.save
      redirect_to admin_facts_path(page: valid_redirect_page), notice: "Fact was successfully created."
    else
      @current_page = params[:page].present? ? params[:page].to_i : 1
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = params[:page].present? ? params[:page].to_i : 1
  end

  def update
    if @fact.update(fact_params)
      redirect_to admin_facts_path(page: valid_redirect_page), notice: "Fact was successfully updated."
    else
      @current_page = params[:page].present? ? params[:page].to_i : 1
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fact.destroy
    redirect_to admin_facts_path(page: valid_redirect_page), notice: "Fact was successfully deleted."
  end

  private

  def set_fact
    @fact = Fact.find(params[:id])
  end

  def fact_params
    params.expect(fact: [ :body ])
  end

  def valid_redirect_page
    return nil if params[:page].blank?

    requested_page = params[:page].to_i
    total_count = Fact.count
    total_pages = [ (total_count.to_f / FACTS_PER_PAGE).ceil, 1 ].max
    requested_page.clamp(1, total_pages)
  end
end
