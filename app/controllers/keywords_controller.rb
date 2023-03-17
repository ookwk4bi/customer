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
    # filedir  = "#{Rails.root}/tmp"
    # @keywordから利用ファイル名の情報を変数filepathに入れる。
    # filepath = "#{filedir}/#{filename}"
    # 変数filenameのファイルを開く処理を変数fpに入れている。
    #fp = open(filename,'r')
    # 変数fpのファイルを開き、ファイルの行数を数え、その情報を変数line_countに入れている
    # line_count = fp.read.count("\n")
    # 行数が70を超えていた場合
    # if line_count >= 75
      # 行数が超えていた場合のメッセージ表示のためflash利用
      # @key = flash[:@key] = "⚠︎利用ファイルのキーワード数を70以下にしてください。"
      # render :new, status: :unprocessable_entity
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
    if line_count >= 51
      @key = flash[:@key] = "⚠︎利用ファイルのキーワード数を50以下にしてください。"
      File.delete(filepath)
      render :new, status: :unprocessable_entity
    elsif @keyword.save
      KeywordJob.perform_async(file_name, @keyword.id)
      redirect_to action: :index
    else
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