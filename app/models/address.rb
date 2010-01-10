# == Schema Information
# Schema version: 20100106152908
#
# Table name: addresses
#
#  id              :integer(4)      not null, primary key
#  zip_code        :string(255)
#  prefecture      :string(255)
#  district        :string(255)
#  town            :string(2048)
#  kana_prefecture :string(255)
#  kana_district   :string(255)
#  kana_town       :string(2048)
#  is_merge        :boolean(1)
#  created_at      :datetime
#  updated_at      :datetime
#
# 郵便番号をあらわす
class Address < ActiveRecord::Base
  #attr_accessor :zip_code, :prefecture, :district, :town, :kana_prefecture, :kana_district, :kana_town, :is_merge
  #attr_accessor :search
  include AttrRelatedMethodDefinable

  # [ [都道府県名, 都道府県順で1からの連番],[..] ]
  PREFECTURES_ORDER = [].tap do |array|
    find(:all, :group=>"prefecture", :select=>"prefecture", :order=>"id ASC").each_with_index do |address, idx|
      array << [address.prefecture, "#{idx+1}"]
    end
  end
  # key   都道府県順で1からの連番
  # value 都道府県名
  PREFECTURES = Hash[*PREFECTURES_ORDER.map(&:reverse).flatten]

  # [ [市区町村名, 市区町村順で1からの連番],[..] ]
  DISTRICTS_ORDER = []
  # key   都道府県名
  # value keyの都道府県名に紐づく市区町村名の配列
  DISTRICTS_ORDER_PER_PREFECTURE_HASH = {}.tap do |hash|
    find(:all, :group=>"district", :order=>"id ASC").each_with_index do |address, idx|
      hash[address.prefecture] ||= []
      hash[address.prefecture] << [address.district, "#{idx+1}"]
      DISTRICTS_ORDER << [address.district, "#{idx+1}"]
    end
  end
  DISTRICTS = Hash[*DISTRICTS_ORDER.map(&:reverse).flatten]

  # インスタンスからアクセスできるマスタ prefecture_mst
  attr_mst :prefecture=>PREFECTURES_ORDER

  # 文字列表現 prefecture_text
  #attr_text :prefecture=>PREFECTURES

  # prefecture_idはDBのIDではない
  # district_idはDBのIDではない
  def self.towns(prefecture_id, district_id)
    hash = {}.tap do |h|
      h[:prefecture] = prefecture_id_to_name(prefecture_id)
      h[:district] =   district_id_to_name(district_id)
    end
    find_by_address(hash)
  end

  # prefecture_idはDBのIDではない
  def self.districts(prefecture_id)
    DISTRICTS_ORDER_PER_PREFECTURE_HASH[prefecture_id_to_name(prefecture_id)]
  end

  def self.prefecture_id_to_name(prefecture_id)
    PREFECTURES[prefecture_id]
  end

  def self.district_id_to_name(district_id)
    DISTRICTS[district_id]
  end

  def self.find_by_zip_code_auto_compate(zip_code)
    (find_by_zip_code(zip_code)||[]).map{|address|
      {
        :prefecture => address.prefecture,
        :district => address.district,
        :town => pre_process_town(address.town)
      }
    }.to_json
  end

  def self.pre_process_town(town)
    if town == "以下に掲載がない場合"
      ""
    elsif /の次に番地がくる場合/ =~ town
      #の次に番地がくる場合を削る
      town.sub(/の次に番地がくる場合/, "")
    else
      town
    end
  end

  def self.find_by_zip_code(zip_code)
    zip_code.gsub!(/-/, "") if zip_code
    find(:all, :conditions=>{:zip_code=>zip_code})
  end

  def self.find_by_address(hash)
    condition_hash=
      {}.tap do |h|
        if prefecture = hash.delete(:prefecture)
          h.merge!(:prefecture=>prefecture)
        end
        if district = hash.delete(:district)
          h.merge!(:district=>district)
        end
        if town = hash.delete(:town)
          h.merge!(:town=>town)
        end
      end
    find(:all, {:conditions=>condition_hash})
  end
end
