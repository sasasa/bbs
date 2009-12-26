#バリデーションエラー時にinputタグなどを囲むタグの設定を変更
# 初期化時に読み込ませる
ActionView::Base.field_error_proc = Proc.new{ |html_tag, instance|
  unless html_tag =~ /<label/
    "<span class=\"fieldWithErrors\">#{html_tag}</span>"
  else
    #labelの際はタグで囲まない
    html_tag
  end
}