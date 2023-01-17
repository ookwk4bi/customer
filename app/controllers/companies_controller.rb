class CompaniesController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @companies = Company.page(params[:page])
    respond_to do |format|
      format.html
      format.csv { send_data @companies.generate_csv, filename: "contents-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to action: :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  # def show
  #   @company = Company.find(params[:id])
  # end

  def edit
    if @company.user_id != current_user.id
      redirect_to root_path
    end
  end

  def update
    @company.update(company_params)
    redirect_to action: :index
  end

  def destroy
    if @company.destroy
      redirect_to action: :index
    else
      render :edit
    end
  end

  def search
    @companies = Company.page(params[:page])
    @company = Company.search(params[:keyword])
  end


  private
    def company_params
      params.require(:company).permit(:name, :address, :url).merge(user_id: current_user.id)
    end

    def set_item
      @company = Company.find(params[:id])
    end
end
