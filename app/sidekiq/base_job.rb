# sidekiqでアイミツ在庫管理システムのCSVファイルを一覧ページに添付し、ダウンロードできる処理。
#baseconnectの処理
require "csv"
class BaseJob
  include Sidekiq::Job
  sidekiq_options queue: :baseconnect_scraping
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

  def perform(baseconnect_id)
    # 引数subject_idのID情報からすべてのカラム情報を取得。
    base = Baseconnect.find_by(id: baseconnect_id)
    filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
    filename = "#{base.base_name}_#{Time.zone.now.strftime('%Y%m%d')}.csv"
    filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
    # ブラウザを起動
    session = capybara#(headless: false) # def capybara ~ end の処理を行っている
    # アイミツSaaS_メールシステム一覧のURLを開く。変数subjectを元にURLを指定している。
    session.visit base.base_url
    sleep(2)
    # html情報をnokogiriで処理
    doc = Nokogiri::HTML.parse(session.html)
    koukoku = doc.xpath("//div[contains(@class,'modalBanner__overlay modalClose-btn')]")
    # 広告の表示があるか確認
    if koukoku.present? # Nokogiri::HTML.parse(session.html).xpath("//span[@class='close-btn']").present?
      # あった場合広告の罰ボタンをクリック。
      session.find("//div[@class='x-btn modalClose-btn']").click
    end
    # 結果格納用配列→CSV保存の処理のため。
    companies = Array.new
    # ループ処理
    100.times do
      begin
        # メールシステム一覧のlinkを取得（aタグ）
        lists = session.all(:xpath, "//h4[@class='searches__result__list__header__title']/a")
        # 取得したメールシステム一覧のaタグ要素をループ処理してパス（セレクター）を取得
        list_paths = lists.map{|element| element.path}
        # パスをループ処理する
        list_paths.each.with_index(1) do |list_path, i|
          # break if i >= 4
          # xpathを元に要素の取得
          list_link = session.find(:xpath, list_path)
          # 要素をホバー
          list_link.hover
          # 要素をクリック
          list_link.click
          sleep(1)
          # html情報をnokogiriで処理
          doc = Nokogiri::HTML.parse(session.html)
          # 会社名と記載したtextがあるdtタグの後ろのddタグのテキスト（⚠︎本当はif分を一つずつ記載するべき）
          # xpathを元に要素のテキストを取得
          name = doc.xpath("//h1[@class='node__header__text__title']").text.squish
          address = doc.xpath("//dt[contains(text(),'住所')]/following-sibling::dd").text.squish
          url = doc.xpath("//a[text()='会社サイト']/@href").text.squish
          puts name #デバック用
          # ハッシュを作成する
          hash = {name: name, address: address, url: url}
          # 結果格納用配列にハッシュを追加する
          companies.push(hash)
          # 元いたタブのhtml情報をnokogiriで処理
          session.go_back
          sleep(1)
        end
        # html情報をnokogiriで処理
        doc = Nokogiri::HTML.parse(session.html)
        # xpathを元に要素の取得
        pages = doc.xpath("//em[@class='current']/following-sibling::a[1]")
        # loop処理を停止するための処理
        # ページ遷移のページリンクがある場合、次のページへのページリンクをクリック。
        if pages.present?
          session.find("//em[@class='current']/following-sibling::a[1]").click
          sleep(1)
        else
          break
        end
      rescue => exception
        puts exception
        puts "処理に失敗したためスクリプトを終了します"
        break
      ensure
        # 必ず処理する内容
      end
    end
    puts "ループ終了"
    begin
      # ループ終了時の現在のブラウザのURLを表示。
      puts session.current_url
      # ブラウザを閉じる
      session.driver.quit
      sleep(1)
    rescue => exception
      puts exception
      puts "ブラウザの操作に失敗しました"
    end
    # スクレイピングした情報を元にCSVのデータを作成
    # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
    bom ="\xEF\xBB\xBF" # bomを作成
    csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
      # ヘッダーの定義
      column_names = %w(会社名 住所 会社URL)
      # ヘッダーの書き込み
      csv << column_names
      # 結果格納用配列をループ処理して値を取り出す
      companies.each do |company|
        # ヘッダーの並びに対応するように配列を作成する
        # company[:name] でハッシュから会社名を取り出す…といった感じ
        column_values = [
          company[:name],
          company[:address],
          company[:url],
        ]
        # データの書き込み
        csv << column_values
      end
    end
    File.open(filepath, "w") do |file|
      file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
    end
    # 作成したCSVファイルを一覧画面(index)に添付。
    base.csv_file.attach(io: File.open(filepath), filename: filename, content_type: "text/csv")
    # 作成したCSVファイルを削除。
    File.delete(filepath)
  end
end