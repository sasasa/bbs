module ShowFieldsOmitable
#  def self.included(recipient)
#    recipient.class_eval do
#      # SELECT * FROM tbl となるべくならないように:selectで全フィールドを指定する
#      # ↓主にfindが
#      # SELECT `tbl`.`field_a`, `tbl`.`field_b` FROM tbl となる
#      # ユーザに踏ませることなくクラスロード時にSHOW FIELDS FROM `tbl`を実行できる
#      # 普通はアプリケーションサーバ再起動後の初回ユーザでSHOW FIELDS FROM `tbl`が１回のみ行われる
#      tbl_name = table_name
#      select_column = column_names.map{|name| "`#{tbl_name}`.`#{name}`"}.join(", ")
#      default_scope :select=>select_column
#    end
#  end
end