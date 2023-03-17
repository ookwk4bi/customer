class BaseconnectsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @bases = Baseconnect.page(params[:page])
  end

  def new
    @base = Baseconnect.new
  end

  def create
    @base = Baseconnect.new(baseconnect_params)
    if @base.save
      BaseJob.perform_async(@base.id)
      redirect_to action: :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @base.destroy
    redirect_to action: :index
  end

  def edit
    if @base.user_id != current_user.id
      redirect_to root_path
    end
  end

  def update
    @base.update(baseconnect_params)
    redirect_to action: :index
  end

  def search
    @bases = Baseconnect.page(params[:page])
    @base = Baseconnect.search(params[:keyword])
  end


  private
    def baseconnect_params
      params.require(:baseconnect).permit(:name, :url, :csv_file).merge(user_id: current_user.id)
    end

    def set_item
      @base = Baseconnect.find(params[:id])
    end
end
