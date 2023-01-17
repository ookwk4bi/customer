class RekaizensController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @rekaizens = Rekaizen.page(params[:page])
  end

  def new
    @rekaizen = Rekaizen.new
  end


  def create
    @rekaizen = Rekaizen.new(rekaizen_params)
    if @rekaizen.save
      RekaizenJob.perform_async(@rekaizen.id)
      redirect_to action: :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @rekaizen.destroy
    redirect_to action: :index
  end

  def edit
    if @rekaizen.user_id != current_user.id
      redirect_to root_path
    end
  end

  def update
    @rekaizen.update(rekaizen_params)
    redirect_to action: :index
  end

  def search
    @rekaizens = Rekaizen.page(params[:page])
    @rekaizen = Rekaizen.search(params[:keyword])
  end

  private
    def rekaizen_params
      params.require(:rekaizen).permit(:rekaizen_name, :rekaizen_url, :csv_file).merge(user_id: current_user.id)
    end

    def set_item
      @rekaizen = Rekaizen.find(params[:id])
    end
end
