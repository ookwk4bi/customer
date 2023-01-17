require "csv"
# 上位サイトKW検索　yahooの取得（ページクリックなし）
namespace :keyword do
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
  task job: :environment do
    # 引数subject_idのID情報からすべてのカラム情報を取得。
    # keyword = Keyword.find_by(id: keyword_id)
    filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
    filename = "上位サイト取得ＫＷ (1).csv"
    filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
    # ブラウザを起動
    session = capybara(headless: false) # def capybara ~ end の処理を行っている
    # アイミツSaaS_メールシステム一覧のURLを開く。変数subjectを元にURLを指定している。
    session.visit 'https://www.yahoo.co.jp/'
    sleep(2)
    # 結果格納用配列→CSV保存の処理のため。
    companies = Array.new
    2.times do |n|
      doc = Nokogiri::HTML.parse(session.html)
      data_list = CSV.read(filepath).map{|row| row[0]}
      puts n
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
      # ループ処理
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
      # xpathを元に要素を取得（aタグ）。
      elements = doc.xpath("//div[@class='sw-Card Algo Algo-anotherSuggest']/section/div[1]/div/div/a")
      # 取得した要素のループ処理
      elements.each do |element|
        # break if i >= 4
        url = element.attribute("href").value
        name = element.xpath("./h3").text
        puts name
        # ハッシュを作成する
        hash = {url: url}
        # 結果格納用配列にハッシュを追加する
        companies.push(hash)
      end
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
    end
    puts companies
    puts "ループ終了"
    # ループ終了時の現在のブラウザのURLを表示。
    puts session.current_url
    # ブラウザを閉じる
    session.driver.quit
    sleep(1)
    # スクレイピングした情報を元にCSVのデータを作成
    # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
    bom ="\xEF\xBB\xBF" # bomを作成
    csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
      # 結果格納用配列をループ処理して値を取り出す
      companies.each.with_index(0) do |company, i|
        # ヘッダーの並びに対応するように配列を作成する
        # company[:name] でハッシュから会社名を取り出す…といった感じ
        puts i
        column_values = [
          company[:url]
        ]
        # データの書き込み
        csv << column_values
      end
    end
    File.open("tmp/上位サイト取得ＫＷ.csv", "w") do |file|
      file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
    end
    # # 作成したCSVファイルを一覧画面(index)に添付。
    # imitsu.csv_file.attach(io: File.open(filepath), filename: filename, content_type: "text/csv")
    # # 作成したCSVファイルを削除。
    # File.delete(filepath)
  end

  task job2: :environment do
    # 引数subject_idのID情報からすべてのカラム情報を取得。
    # keyword = Keyword.find_by(id: keyword_id)
    filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
    filename = "上位サイト取得ＫＷ.csv"
    filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
    # ブラウザを起動
    session = capybara#(headless: false) # def capybara ~ end の処理を行っている
    # アイミツSaaS_メールシステム一覧のURLを開く。変数subjectを元にURLを指定している。
    session.visit 'https://www.yahoo.co.jp/'
    sleep(2)
    2.times do |n|
      # 結果格納用配列→CSV保存の処理のため。
      companies = Array.new
      doc = Nokogiri::HTML.parse(session.html)
      data_list = CSV.read(filepath).map{|row| row[0]}
      puts n
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
      # ループ処理
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
      # xpathを元に要素を取得（aタグ）。
      elements = doc.xpath("//div[@class='sw-Card Algo Algo-anotherSuggest']/section/div[1]/div/div/a")
      # 取得した要素のループ処理
      elements.each do |element|
        # break if i >= 4
        url = element.attribute("href").value
        # 結果格納用配列にurlを追加する
        companies.push(url)
      end
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
      puts companies
      # スクレイピングした情報を元にCSVのデータを作成
      # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
      bom ="\xEF\xBB\xBF" # bomを作成
      csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
        # 結果格納用配列をループ処理して値を取り出す
          # ヘッダーの並びに対応するように配列を作成する
          # company[:name] でハッシュから会社名を取り出す…といった感じ
          column_values = [
            data_list[n],
            companies[0],
            companies[1],
            companies[2],
            companies[3],
            companies[4],
            companies[5],
            companies[6],
            companies[7],
            companies[8],
            companies[9],
          ]
          # データの書き込み
          csv << column_values
      end
      File.open("tmp/大桑和樹.csv", "a") do |file|
        file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
      end
    end
    puts "ループ終了"
      # ループ終了時の現在のブラウザのURLを表示。
      puts session.current_url
      # ブラウザを閉じる
      session.driver.quit
      sleep(1)
    # # 作成したCSVファイルを一覧画面(index)に添付。
    # imitsu.csv_file.attach(io: File.open(filepath), filename: filename, content_type: "text/csv")
    # # 作成したCSVファイルを削除。
    # File.delete(filepath)
  end
  # 上位サイトKWの完成系です
  task job3: :environment do
    # 引数subject_idのID情報からすべてのカラム情報を取得。
    # keyword = Keyword.find_by(id: keyword_id)
    filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
    filename = "上位サイト取得ＫＷ.csv"
    filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
    fp = open(filepath,'r')
    line_count = fp.read.count("\n")
    puts line_count
    if line_count > 50
      exit
    end
    # ブラウザを起動
    session = capybara(headless: false) # def capybara ~ end の処理を行っている
    # アイミツSaaS_メールシステム一覧のURLを開く。変数subjectを元にURLを指定している。
    session.visit 'https://www.yahoo.co.jp/'
    sleep(2)
    data_list1 = Array.new
    10.times do |n|
      companies = Array.new
      # 結果格納用配列→CSV保存の処理のため。
      doc = Nokogiri::HTML.parse(session.html)
      data_list = CSV.read(filepath).map{|row| row[0]}
      p data_list
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
      # ループ処理
      # html情報をnokogiriで処理
      doc = Nokogiri::HTML.parse(session.html)
      # xpathを元に要素を取得（aタグ）。
      elements = doc.xpath("//div[@class='sw-Card Algo Algo-anotherSuggest']/section/div[1]/div/div/a")
      elements.each.with_index(0) do |element, i|
        # break if i >= 4
        data_list = CSV.read(filepath).map{|row| row[0]}
        url = element.attribute("href").value
        # 結果格納用配列にurlを追加する
        if i >= 1
          companies << url
        else
          companies << data_list[n]
          companies << url
        end
      end
      data_list1 << companies
      # html情報をnokogiriで処理
    end
    doc = Nokogiri::HTML.parse(session.html)
      # スクレイピングした情報を元にCSVのデータを作成
      # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
      bom ="\xEF\xBB\xBF" # bomを作成
      csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
        # 結果格納用配列をループ処理して値を取り出す
        # ヘッダーの並びに対応するように配列を作成する
        # company[:name] でハッシュから会社名を取り出す…といった感じ
        # column_values << n + 1
        data_list1.each do |company|
          csv << company
        end
      end
      File.open("tmp/大桑和樹.csv", "w") do |file|
        file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
      end
    puts "ループ終了"
      # ループ終了時の現在のブラウザのURLを表示。
      puts session.current_url
      # ブラウザを閉じる
      session.driver.quit
      sleep(1)
    # # 作成したCSVファイルを一覧画面(index)に添付。
    # imitsu.csv_file.attach(io: File.open(filepath), filename: filename, content_type: "text/csv")
    # # 作成したCSVファイルを削除。
    # File.delete(filepath)
  end
  task job4: :environment do
 # 引数subject_idのID情報からすべてのカラム情報を取得。
 keyword = Keyword.find_by(id: keyword_id)
 filedir  = "#{Rails.root}/tmp" # tmp配下に保存されて欲しいのでtmpのディレクトリパスを変数に入れる
 filename = "#{keyword.open_filename}.csv"
 filename1 = "#{keyword.save_filename}.csv"
 save_filename = "#{filedir}/#{filename1}"
 filepath = "#{filedir}/#{filename}" # フォルダのパスとファイル名を組み合わせて、ファイルのフルパスを作り変数に入れる。
 # ブラウザを起動
 session = capybara(headless: false) # def capybara ~ end の処理を行っている
 # アイミツSaaS_メールシステム一覧のURLを開く。変数subjectを元にURLを指定している。
 session.visit 'https://www.yahoo.co.jp/'
 sleep(2)
 2.times do |n|
   # 結果格納用配列→CSV保存の処理のため。
   companies = Array.new
   doc = Nokogiri::HTML.parse(session.html)
   data_list = CSV.read(filepath).map{|row| row[0]}
   puts n
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
   # ループ処理
   # html情報をnokogiriで処理
   doc = Nokogiri::HTML.parse(session.html)
   # xpathを元に要素を取得（aタグ）。
   elements = doc.xpath("//div[@class='sw-Card Algo Algo-anotherSuggest']/section/div[1]/div/div/a")
   elements.each do |element|
     # break if i >= 4
     url = element.attribute("href").value
     # 結果格納用配列にurlを追加する
     hash = {url: url}
     companies.push(hash)
   end
   # html情報をnokogiriで処理
   doc = Nokogiri::HTML.parse(session.html)
   puts companies
   # スクレイピングした情報を元にCSVのデータを作成
   # Windowsで開くことを想定しているのでUTF-8 BOM付きのCSVファイルを作成する
   bom ="\xEF\xBB\xBF" # bomを作成
   csv_data = CSV.generate(bom, force_quotes: true) do |csv| # bomをラップしてブロックに渡す
     # 結果格納用配列をループ処理して値を取り出す
     # ヘッダーの並びに対応するように配列を作成する
     # company[:name] でハッシュから会社名を取り出す…といった感じ
     column_values = Array.new
     column_values << n + 1
     column_values << data_list[n]
     companies.each do |company|
       column_values << company[:url]
     end
     csv << column_values
     puts csv
   end
   File.open(save_filename, "a") do |file|
     file.write(csv_data) # ここで最初に指定したファイルに対してCSVのデータが書き込まれる
   end
 end
 # table = CSV.table(save_filename)
 # table.by_col!.delete(:col1)
 # File.write(save_filename, table)
 # 作成したCSVファイルを一覧画面(index)に添付。
 keyword.csv_file.attach(io: File.open(save_filename), filename: filename1, content_type: "text/csv")
 # 作成したCSVファイルを削除。
 # File.delete(save_filename)
 puts "ループ終了"
   # ループ終了時の現在のブラウザのURLを表示。
   puts session.current_url
   # ブラウザを閉じる
   session.driver.quit
   sleep(1)
 # # 作成したCSVファイルを一覧画面(index)に添付。
 # imitsu.csv_file.attach(io: File.open(filepath), filename: filename, content_type: "text/csv")
 # # 作成したCSVファイルを削除。
 # File.delete(filepath)
end
end  
