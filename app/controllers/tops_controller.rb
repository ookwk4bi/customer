class TopsController < ApplicationController
  def index
    @tops = Company.page(params[:page])
  end
end
