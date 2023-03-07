# sidekiqでアイミツ在庫管理システムのCSVファイルを一覧ページに添付し、ダウンロードできる処理。
#アイミツのSaaSの処理
require "csv"
class KeywordJob
  include Sidekiq::Job
  sidekiq_options queue: :keyword_scraping
  # Sidekiq::Queue['my_queue'].limit = 1 いらない疑惑
  def capybara(mobile: false, headless: true, images_disabled: true)
    # Capybara自体の設定、ここではどのドライバーを使うかを設定しています
    Capybara.configure do |config|
      config.run_server = false
      config.default_driver = :selenium_chrome
      config.javascript_driver = :selenium_chrome
      config.default_selector = :xpath
      config.default_max_wait_time = 60
    end
    # Capybaraに設定したドライバーの設定をします
    Capybara.register_driver :selenium_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_preference(:download, default_directory: "tmp/download")            # ダウンロードディレクトリを指定
      options.add_emulation(device_name: 'iPhone X') if mobile                        # mobile: true だった場合はモバイルの設定を追加
      options.add_argument('--no-sandbox')                                            # サンドボックスを無効化
      options.add_argument('--disable-dev-shm-usage')                                 # 共有メモリファイルの設定# エラーの許容
      options.add_argument('--disable-desktop-notifications')                         # デスクトップ通知の無効化
      options.add_argument('--disable-extensions')                                    # 拡張機能の無効化
      options.add_argument('--disable-web-security')                                  # クロスドメイン制約を回避
      options.add_argument('--ignore-certificate-errors')                             # 証明書の警告を無効化
      options.add_argument('--allow-running-insecure-content')                        # 混合コンテンツの許可
      options.add_argument('--window-size=1280,800')                                  # ウィンドウサイズの指定（デフォルトの800x600だと小さすぎるため）
      options.add_argument('--lang=ja')                                               # 言語設定
      options.add_argument('--blink-settings=imagesEnabled=false') if images_disabled # 画像を読み込まない
      options.add_argument('disable-infobars')                                        # INFOの非表示
      options.add_argument('headless') if headless                                    # ヘッドレスモードをonにするオプション
      if File.exist?("tmp/user_agent.txt") && headless                                # headlessがオンになっているかつuser_agent.txtのファイルが存在する場合
        user_agent = File.read("tmp/user_agent.txt")                                  # user_agent.txtの内容を読み込み、結果を変数に入れる。
        options.add_argument("--user-agent=#{user_agent}")                            # ユーザーエージェント
      end
      Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
    end
    Capybara.ignore_hidden_elements = false
    Capybara.javascript_driver = :selenium_chrome
    return Capybara::Session.new(:selenium_chrome)
  end

  def perform(keyword_id)
    # 引数keyword_idのID情報からすべてのカラム情報を取得。
    keyword = Keyword.find_by(id: keyword_id)
    filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
    # 登録情報の利用ファイル名の情報を変数filenameに入れる
    filename = "#{keyword.open_filename}.csv"
    # 登録情報の保存ファイル名の情報を変数filenameに入れる
    filename1 = "#{keyword.save_filename}.csv"
    # tmp配下の保存ファイル名の変数を作る（フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。）。
    save_filename = "#{filedir}/#{filename1}"
    filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
    # ブラウザを起動
    session = capybara#(headless: false) # def capybara ~ end の処理を行っている
    # アイミツSaaS_メールシステム一覧のURLを開く。変数subjectを元にURLを指定している。
    session.visit 'https://www.yahoo.co.jp/'
    sleep(2)
    # 変数companiesの配列を全格納する配列作成→CSV保存の処理のため。
    arrangements = Array.new
    # ループ処理
    keyword.number.times do |n|
      # 結果格納用配列→CSV保存の処理のため。
      companies = Array.new
      doc = Nokogiri::HTML.parse(session.html)
      # 変数failepathを元にファイルの1列目を読み取り、読み取った情報を変数に入れている。
      data_list = CSV.read(filepath).map{|row| row[0]}
      # 次のキーワードが取得できない場合、処理を終了する
      unless data_list[n].present?
        break
      end
      # yahooページのトップの検索フォームと２回目以降の検索フォームが違うため条件分岐で分けている。
      if n >= 1
        session.find("(//input[@class='SearchBox__searchInput js-SearchBox__searchInput'])[1]").set("#{data_list[n]}")
        sleep(1)
        session.find(:xpath, "(//span[@class='SearchBox__searchButtonText'])[1]").click
        sleep(1)
      else
        session.find("//input[@class='_1wsoZ5fswvzAoNYvIJgrU4']").set("#{data_list[n]}")
        sleep(1)
        session.find(:xpath, "//button[@class='_63Ie6douiF2dG_ihlFTen cl-noclick-log']").click
        sleep(1)
      end
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
      # xpathを元に要素を取得（aタグ）。
      elements = doc.xpath("//div[@class='sw-Card Algo Algo-anotherSuggest']/section/div[1]/div/div/a")
      elements.each.with_index(0) do |element, i|
        # break if i >= 4
        # 変数failepathを元にファイルの1列目を読み取り、読み取った情報を変数に入れている。
        data_list = CSV.read(filepath).map{|row| row[0]}
        # aタグ要素のhref属性の値を取得。
        url = element.attribute("href").value
        # 結果格納用配列にurlを追加する処理（1回目にキーワード名を格納したいので条件式を利用）
        if i >= 1
          companies << url
        else
          companies << data_list[n]
          companies << url
        end
      end
      # 結果格納用配列にcompaniesを追加する処理（キーワード毎のyahooの１ページ目のリンク情報を配列にしてcompaniesを追加している）
      puts companies
      arrangements << companies
    end
    # html情報をnokogiriで処理
    doc = Nokogiri::HTML.parse(session.html)
    # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
    bom ="\xEF\xBB\xBF" # bomを作成
    csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
      # 結果格納用配列をループ処理して値を取り出す
      arrangements.each do |arrangement|
        # データの書き込み
        csv << arrangement
      end
    end
    # 作成したデータをファイルに書き込み
    File.open(save_filename, "w") do |file|
      file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
    end
    # 作成したCSVファイルを一覧画面(index)に添付。
    keyword.csv_file.attach(io: File.open(save_filename), filename: filename1, content_type: "text/csv")
    # 作成したCSVファイルを削除。
    File.delete(save_filename)
    puts "ループ終了"
    # ループ終了時の現在のブラウザのURLを表示。
    puts session.current_url
    # ブラウザを閉じる
    session.driver.quit
    sleep(1)
  end
end