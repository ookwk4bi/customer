class AimitsusController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @aimitsus = Aimitsu.page(params[:page])
  end

  def new
    @aimitsu = Aimitsu.new
  end

  def create
    @aimitsu = Aimitsu.new(params_aimitsu)
    if @aimitsu.save
      AimitsuJob.perform_async(@aimitsu.id)
      redirect_to action: :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @aimitsu.destroy
    redirect_to action: :index
  end

  def edit
    if @aimitsu.user_id != current_user.id
      redirect_to root_path
    end
  end

  def update
    @aimitsu.update(params_aimitsu)
    redirect_to action: :index
  end

  def search
    @aimitsus = Aimitsu.page(params[:page])
    @aimitsu = Aimitsu.search(params[:keyword])
  end


  private
    def params_aimitsu
      params.require(:aimitsu).permit(:aimitsu_name, :aimitsu_url, :csv_file).merge(user_id: current_user.id)
    end

    def set_item
      @aimitsu = Aimitsu.find(params[:id])
    end
end
