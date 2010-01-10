require 'fastercsv'

# モデルクラス名を与えるとそのデータをすべてCSVとして出力する
# 
# 出力するカラムはデフォルトでは全てのカラム
# モデルクラスにクラスメソッドを定義していた場合はそちらを優先する
# dbの検索オプションに:selectで指定したカラムが最優先される
#
# model_clazz: 出力するモデル名
# opt: 検索条件
# file_name: ファイル名
# write_headers: ヘッダを出力するか
# コントローラーで以下のように呼び出す
# send_data(*CSV_Downloader.create_download_data(Category))
# send_data(*CSV_Downloader.create_download_data(Category, :conditions=>{:parent_id=>nil}))
# send_data(*CSV_Downloader.create_download_data(Category, :conditions=>{:parent_id=>nil}, :select=>"id, name"))
module CSV_Downloader
  def create_download_data(model_clazz, 
      db_opt={},
      csv_opt={:file_name=>"#{model_clazz.name.tableize}_data_#{Time.now.strftime("%Y%m%d")}.csv",
               :write_headers=>true})

    models = model_clazz.find(:all, db_opt)

    #モデルクラスにcsv_col_namesというメソッドがあるとそちらのデータを利用する
    col_names =
      if db_opt[:select]
        db_opt[:select].split(/,/).map(&:jstrip)
      else
        defined?(model_clazz.csv_col_names) ? model_clazz.csv_col_names : model_clazz.column_names
      end


    #ヘッダを日本語に変換した結果(config/locales/translation_ja.yml)
    col_jp_names =
      col_names.map do |name|
        I18n.t(name, :scope=>[:activerecord, :attributes, model_clazz.name.underscore])
      end

    output = FasterCSV.generate(:headers => col_jp_names, :write_headers => csv_opt[:write_headers]) do |csv|
      models.each { |model| csv << col_names.map {|column| model.send(column)} }
    end

    [NKF.nkf('-m0 -x -Ws', output), { :type=>'text/csv', :filename=>csv_opt[:file_name] }]
  end
  module_function :create_download_data
end