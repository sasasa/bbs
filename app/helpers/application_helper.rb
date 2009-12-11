# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # 囲む系統のタグの内側でループを出力する際、不必要なタグを出力しないようにする
  def condition_content_tag(tag, condition_obj, *arg, &block)
    content_tag(tag, *arg, &block) if condition_obj && condition_obj.has_children?
  end
  
  # ログインしていなくても以下のページの際は「ログイン」というリンクを表示させない
  def login_link_necessary?
    request_url = request.url
    request_url != login_url &&
    request_url != signup_url &&
    request_url != users_url &&
    request_url != session_url &&
    request_url != new_user_url &&
    request_url != new_session_url
  end
  
  # 「カテゴリの詳細ページ」へリンクを作成。再下層のときは「質問一覧」へリンクを作成
  def rightly_link_to(category)
    link_to h(category.name), category.has_children? ? category_path(category) : category_questions_path(category, :page=>"1")
  end

  # 時間の表示フォーマット
  def format_str(time)
    time.strftime("%y/%m/%d %H:%M")
  end

  # ラジオボタンのときにラベル
  def label_for_radio_button( f, attr, i, text )
    f.label attr, h(text), :for=>"#{f.object.class.to_s.underscore}_#{attr}_#{i}"
  end

  # 改行を<br />に変換
  def h_br(text)
    h(length_limitation(text)).gsub(/\n/, "<br />")
  end

  # 一行あたりの文字数がlimitを超えると自動で改行コードを挿入する
  # word-break が効かないFirefoxなどでテーブルの枠が際限無く広がるのを防止
  def length_limitation(input_text, limit=60)
    changed =
      input_text.map do |row|
        ret_text =
          "".tap do |txt|
            row_length = row.jlength
            # 行の長さがlimitを超えていてかつ全てアルファベットや数値や記号のみのとき
            while row_length >= limit && row =~ /^[[:alnum:][:punct:]]+$/
                row[limit,0] = "\n"
                txt << row[0,limit+1]
                row = row[limit+1, row.jlength]
                row_length = row.jlength
            end
          end
        ret_text.blank? ? row : ret_text
      end
    changed.join("")
  end

  def page_name
    controller_name + "_" + action_name
  end

  # ログインしていなければ専用のクラス名をつける
  def login_prefix(text)
    if logged_in?
      text
    else
      ["ログインして" + text, {:class=>"no_login submit"}]
    end
  end

  # パンくずリスト成形
  def topic_path_link(limit=24)
    @topic_path.compact!
    unless @topic_path.blank?
      #パンくずの先頭にはホームへのリンク
      @topic_path.unshift([t("Home"), root_path])
      #最後はリンクを張らない
      last_text = truncate(@topic_path.pop[0], :length=>limit)
      ret_texts =
        @topic_path.map do |text, path|
          text = truncate(text, :length=>limit)
          link_to(h(text), path) + "&nbsp;&lt;&nbsp;"
        end
      ret_texts.join("") + h(last_text)
    end
  end

  #XSS pluginによって今までHTMLタグを出力していたメソッドを指定する
  safe_helper :topic_path_link, :h_br
end
