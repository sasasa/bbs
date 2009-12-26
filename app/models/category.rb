# == Schema Information
# Schema version: 20091108170711
#
# Table name: categories
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  parent_id          :integer(4)
#  is_most_underlayer :boolean(1)
#  created_at         :datetime
#  updated_at         :datetime
#

class Category < ActiveRecord::Base
  include ShowFieldsOmitable

  acts_as_cached right_ttl

  #安全に倒してホワイトリストとするためカラム追加時に忘れないこと
  attr_accessible :name

  acts_as_tree :order=>'id'
  has_many :questions, :dependent => :destroy, :order => 'created_at desc'

  named_scope :include, :include=>{:children=>:children}

  #acts_as_tree の rootを上書き
  named_scope :root,    :conditions => ["categories.parent_id IS NULL"], :order => 'id'
  #acts_as_tree の rootsを上書き
  named_scope :roots,    :conditions => ["categories.parent_id IS NULL"], :order => 'id'

  # 最下層かどうかのフラグを設定する テストデータ作成のバッチで使用
  def most_underlayer_setting
    # 下の階層が無いのに最下層フラグが立っていない時
    if !is_most_underlayer && children.blank?
      self.is_most_underlayer = true
      save
    end
    # 登録する際自分の親の階層の最下層フラグをオフにする
    if parent && parent.is_most_underlayer
      parent.is_most_underlayer = false
      parent.save
    end
  end

  def has_children?
    !is_most_underlayer
  end

  def self.cache_include_find(parent_id)
    Category.get_cache("Category.cache_include_find(#{parent_id})") do
      include.find(parent_id)
    end
  end

  # カテゴリごとカラムに分けるため各サブカテゴリを等分して取得する
  # col_num 分割したいカラム数
  # 分割したサブカテゴリ
  def children_every_col(col_num = 2)
    children.in_groups(col_num, false)
  end

  # カテゴリごとカラムに分けるため各カテゴリを等分して取得する
  # col_num 分割したいカラム数
  # 分割したカテゴリ
  def self.cache_root_categories_every_col(col_num = 3)
    Category.get_cache("Category.cache_root_categories_every_col(#{col_num})") do
      roots.include.in_groups(col_num, false)
    end
  end

  def cache_ancestors
    Category.get_cache("Category#cache_ancestors_#{self.id}") do
      ancestors
    end
  end
end
