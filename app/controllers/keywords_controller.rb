class KeywordsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]
  def index
    @keywords = Keyword.page(params[:page])
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)
    if @keyword.open_filename.attached? && @keyword.open_filename.content_type == 'text/csv'
      uploaded_file = params[:keyword][:open_filename]
      filedir  = "#{Rails.root}/tmp"
      csv_data = uploaded_file.read
      file_name = uploaded_file.original_filename
      filepath = "#{filedir}/#{file_name}"
      File.open(filepath, 'wb') do |file|
        file.write(csv_data)
      end
      fp = open(filepath,'r')
      line_count = fp.read.count("\n")
      if line_count >= 11
        @key = flash[:@key] = "⚠︎利用ファイルのキーワード数を10以下にしてください。"
        File.delete(filepath)
        render :new, status: :unprocessable_entity
      elsif @keyword.save
        KeywordJob.perform_async(file_name, @keyword.id)
        redirect_to action: :index
      else
        render :new, status: :unprocessable_entity
      end
    else
      @key = flash[:@key] = "⚠︎CSVファイルが添付されていません"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if current_user.id != @keyword.user_id
      redirect_to root_path
    end
  end

  def update
    @keyword.update(keyword_params)
    redirect_to action: :index
  end

  def destroy
    @keyword.destroy
    redirect_to action: :index
  end

  def show

  end
  def search
    @keywords = Keyword.page(params[:page])
    @keyword = Keyword.search(params[:keyword])
  end

  private
    def keyword_params
      params.require(:keyword).permit(:open_filename, :save_filename, :csv_file).merge(user_id: current_user.id)
    end

    def set_item
      @keyword = Keyword.find(params[:id])
    end
end