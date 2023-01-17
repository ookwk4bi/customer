# リスティング広告を取得するバージョン。
require "csv"
# yahooの取得（ページクリックなし）
namespace :listing do
  using Module.new {
    refine Object do
      # Chrome
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
    end
  }
  # CSV前の（puts 処理）
  task yahoo1: :environment do
    filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
    filename = "リスティング1.csv" # 保存するCSVの名前。適宜変更する。
    filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
    data_list = "沖縄　注文住宅"
    # ブラウザを起動
    session = capybara(headless: false) # def capybara ~ end の処理を行っている
    # yahooのトップページに遷移
    session.visit 'https://www.yahoo.co.jp/'
    sleep(2)
    # 検索フォームにSEOという文字を入力
    session.find("//input[@class='_1wsoZ5fswvzAoNYvIJgrU4']").set("#{data_list}")
    sleep(1)
    # 検索ボタンをクリック
    session.find(:xpath, "//button[@class='_63Ie6douiF2dG_ihlFTen cl-noclick-log']").click
    sleep(1)

    # timesでも良いが変数nが０スタートなので数字がわかりにくいので、uptoを使用。
    # 処理を10回繰り返す。
    companies = Array.new
    1.upto(3) do |n|
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
      # xpathを元に要素を取得（aタグ）。
      elements = doc.xpath("//div[@class='sw-Card Ad js-Ad']/section/div[1]/div/div/a")
      # ("//div[@class='sw-Card Ad js-Ad']/section/div[1]/div/div/div/div/cite")
      # 取得した要素のループ処理
      elements.each do |element|
        # aタグ内のh3タグのテキストを取得。.で現在地を示している。
        name = element.xpath("./h3").text
        # aタグ要素のhref属性の値を取得。
        url = element.xpath("./div/div/cite").text
        # ハッシュを作成する
        hash = {data: data_list, name: name, url: url}
        # 結果格納用配列にハッシュを追加する
        companies.push(hash)
      end
      # xpathを元に要素を取得（次のページ遷移のaタグ）
      page = doc.xpath("(//strong/following-sibling::a)[1]")
      # 10回目のループ処理で11ページへ移動しないように条件式を書く。
      # 処理が10回目に達した場合または次のページがなかった場合、処理を終了する。
      if n >= 3 || page.blank?
        break
      else
        # それ以外の場合、次のページへのリンクをクリック。
        session.find("(//strong/following-sibling::a)[1]").click
        sleep(2)
      end
    end
    puts "ループ終了"
    # ループ処理終了時の現在のブラウザのURLを表示。（デバック用）
    puts session.current_url
    # ブラウザを閉じる
    session.driver.quit
    sleep(1)
    # スクレイピングした情報を元にCSVのデータを作成
    # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
    bom ="\xEF\xBB\xBF" # bomを作成
    csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
      # 結果格納用配列をループ処理して値を取り出す
      # ヘッダーの定義
      # column_name = %w(キーワード アンカーテキスト リンク)
      # # ヘッダーの書き込み
      # csv << column_name
      companies.each do |company|
        # ヘッダーの並びに対応するように配列を作成する
        # company[:name] でハッシュから会社名を取り出す…といった感じ
        column_values = [
          company[:data],
          company[:name],
          company[:url]
        ]
        # データの書き込み
        csv << column_values
      end
    end
    # 作成したデータをファイルに書き込み
    File.open(filepath, "a") do |file|
      file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
    end
  end
end