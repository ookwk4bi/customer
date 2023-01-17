class ImitsusController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]
  def index
    @imitsus = Imitsu.page(params[:page])
  end

  def new
    @imitsu = Imitsu.new
  end

  def create
    @imitsu = Imitsu.new(imitsu_params)
    if @imitsu.save
      SampleJob.perform_async(@imitsu.id)
      redirect_to action: :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @imitsu.destroy
    redirect_to action: :index
  end

  def edit
    if @imitsu.user_id != current_user.id
      redirect_to root_path
    end
  end

  def update
    @imitsu.update(imitsu_params)
    redirect_to action: :index
  end

  def search
    @imitsus = Imitsu.page(params[:page])
    @imitsu = Imitsu.search(params[:keyword])
  end


  private
    def imitsu_params
      params.require(:imitsu).permit(:imitsu_name, :imitsu_url, :csv_file).merge(user_id: current_user.id)
    end

    def set_item
      @imitsu = Imitsu.find(params[:id])
    end
end
