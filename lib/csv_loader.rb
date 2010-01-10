require 'fastercsv'
require 'csv'
require 'nkf'

module CSV_Loader
  CSV_PATH = "#{RAILS_ROOT}/db/data/ken_all.csv"
  CSV_UTF_PATH = "#{RAILS_ROOT}/db/data/ken_all.csv.UTF8"

  # CSV文字コード変換
  def init
    puts "file encoding modify start"
    open(CSV_PATH) {|source|
      open(CSV_UTF_PATH, "w") {|dest|
        dest.write( NKF.nkf('-m0 -x -Sw', source.read.gsub("\r\n", "\n" )) )
      }
    }
    puts "file encoding modify stop"
  end

  # CSV読み込み後にDBに入れる
  def load
    puts "csv load start"
    CSV.foreach(CSV_UTF_PATH){|row|
      Address.create(:zip_code=>row[2],
                    :prefecture=>row[6],
                    :district=>row[7],
                    :town=>row[8],
                    :kana_prefecture=>NKF::nkf('-Ww', row[3]),#半角カナ変換
                    :kana_district=>NKF::nkf('-Ww', row[4]),
                    :kana_town=>NKF::nkf('-Ww', row[5]),
                    :is_merge=>row[12])
    }
    puts "csv load stop"
    puts "load number is " + Address.count.to_s
  end

  # CSV読み込み後にDBに入れる
  def fast_load
    puts "csv load start"
    opt = {:col_sep => ",", :quote_char => '"', :headers => false, :row_sep=>:auto }
    FasterCSV.foreach(CSV_UTF_PATH, opt) do |row|
      Address.create(:zip_code=>row[2],
                    :prefecture=>row[6],
                    :district=>row[7],
                    :town=>row[8],
                    :kana_prefecture=>NKF::nkf('-Ww', row[3]),#半角カナ変換
                    :kana_district=>NKF::nkf('-Ww', row[4]),
                    :kana_town=>NKF::nkf('-Ww', row[5]),
                    :is_merge=>row[12])
    end
    puts "csv load stop"
    puts "load number is " + Address.count.to_s#122883-122554
  end

  def modify
    #集計用
    merge_zip_code_num = 0
    merge_row = 0

    #郵便番号でグループ化すると2行以上ありフラグが０のもの
    hash_per_zip_code = Address.count(:all, :conditions=>{:is_merge=>false}, :group=>"zip_code", :having=>"count(zip_code) >= 2", :select=>"zip_code")
    hash_per_zip_code.keys.each do |zip_code|
      merge_zip_code_num += 1
      puts "merge0! #{zip_code}"
      town_txt = ""
      kana_town_txt = ""
      address_array = Address.find(:all, :conditions=>{:zip_code=>zip_code}, :order=>"id ASC")
      address_array.each do |address|
        town_txt << address.town
        kana_town_txt << address.kana_town
      end
      puts "town_txt0 is #{town_txt}"
      address_array.each_with_index do |address, idx|
        if idx==0
          address.town = town_txt
          address.kana_town = kana_town_txt
          address.save
          puts "modify0 add id #{address.id}"
        else
          address.destroy
          puts "modify0 destroy id #{address.id}"
        end
        merge_row += 1
      end
    end

    #郵便番号でグループ化すると2行以上ありフラグが1で「（」「）」にはさまれているところ
    merge_hash_per_zip_code = Address.count(:all, :conditions=>{:is_merge=>true}, :group=>"zip_code", :having=>"count(zip_code) >= 2", :select=>"zip_code")
    merge_hash_per_zip_code.keys.each do |zip_code|
      town_txt = ""
      kana_town_txt = ""
      modify_address_objs = []
      is_merge = false

      address_array = Address.find(:all, :conditions=>{:zip_code=>zip_code}, :order=>"id ASC")
      address_array.each do |address|
        if /[^（）]*）$/ =~ address.town && is_merge
          #「）」のおわりの行
          town_txt << address.town
          kana_town_txt << address.kana_town
          modify_address_objs << address
          puts "town_txt1 is #{town_txt}"
          is_merge = false

          #括弧が閉じたときに「（」「）」にはさまれているところを更新する
          modify_address_objs.each_with_index do |address, idx|
            merge_row += 1
            if idx==0
              address.town = town_txt
              address.kana_town = kana_town_txt
              address.save
              puts "modify1 add id #{address.id}"
            else
              address.destroy
              puts "modify1 destroy id #{address.id}"
            end
          end
        elsif /[^（）]*（[^）]+$/ =~ address.town && !is_merge
          #「（」のはじまりの行
          puts "merge!1 #{zip_code}"
          merge_zip_code_num += 1

          town_txt = ""
          kana_town_txt = ""
          modify_address_objs = []
          is_merge = true

          town_txt << address.town
          kana_town_txt << address.kana_town
          modify_address_objs << address
        elsif /^[^（）]+$/ =~ address.town && is_merge
          #「（」と「）」の真ん中の行
          town_txt << address.town
          kana_town_txt << address.kana_town
          modify_address_objs << address
        end
      end
    end
    puts "マージした郵便番号の数:#{merge_zip_code_num}件"#228
    puts "マージした行数:#{merge_row}件"#557
  end

  module_function :load, :fast_load, :init, :modify
end
