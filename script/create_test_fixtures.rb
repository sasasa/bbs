require 'rubygems'
require 'activesupport'
require 'activerecord'
#ruby script/runner 'script/create_test_fixtures.rb'
#users fixture
users_start_num=10
users_end_num=1000

File.open("user_fixture.txt",'w'){|file|
  (users_start_num..users_end_num).each do |i|
	file.puts <<-"EOF"
testu#{i}:
  id:                        #{i}
  login:                     sasasa#{i}
  name:                     名#{i} 太郎
  email:                     masaakisaeki#{i}@gmail.com
  salt:                      abdf5db3fe2b8fd7bfba77c74806a38cf6eea0ae
  crypted_password:        33e19f4f8f824ef64702afadac530fa24c868c64
  created_at:               2009-11-07 07:50:53
  updated_at:               2009-11-07 07:51:16
  activated_at:             2009-11-07 07:51:16
  state:                    #{["pending","active","active","active","active","active"].rand}
EOF
  end
}

question_start_num=100
question_end_num=5000
question_range = (question_start_num..question_end_num)
users = User.all
categories = Category.all.find_all{|cate| !cate.has_children? }
time = Time.now

File.open("question_fixture.txt",'w'){|file|
  question_range.each do |i|
    time -= 1
	  file.puts <<-"EOF"
testu#{i}:
  id:                        #{i}
  title:                     #{i}ＳＩＭロック解除アダプタでＳＩＭ内の情報は読み込めてるのにずっと圏外のままで...
  content: |
    #{i}ＮＺ在住の者です。先日亡くなった身内が買ったばかりの日本の携帯をＮＺに持ってきました。

    そのままではＮＺでは使えないので、知り合いに勧められてＳＩＭロック解除アダプターをヤフオクで購入し、日本から昨日届いたので、ＮＺで使っていた携帯からＳＩＭを取り出してアダプターと一緒に入れてみました。ところが、ＳＩＭ内の情報は取り込めているようなのですが、圏外のままです。
    メールフォルダにはちゃんと今まで届いたメールが入っています。アドレス帳もちゃんと見れます。ただ、ずっと圏外のままなんです。電話も何もできません。
    知り合いに聞いたところ、ネットワークを手動で選べばいいと言われ、携帯が探知したＮＺのネットワークを手動で選んでみましたが、うまくいきません。
    どなたか、アドバイスをお願いします！

    ちなみに、携帯の機種はドコモのＮ０２Aです。
    解決法以外の書き込みはご遠慮ください。
  state:                     #{Question::STATES.keys.rand}
  is_closed:                 #{[true,false].rand}
  receive_mail:              #{[true,false].rand}
  user_id:                   #{users.rand.id}
  category_id:               #{categories.rand.id}
  created_at:                #{time.to_s(:db)}
  updated_at:                #{time.to_s(:db)}
EOF
  end
}


answer_start_num=100
answer_end_num=10000
time = Time.now

File.open("answer_fixture.txt",'w'){|file|
  (answer_start_num..answer_end_num).each do |i|
    time -= 1
    is_output_supplement_comment = [false,false,false,false,true].rand

    comment = "| \n    #{i}とてもするどい指摘をありがとうございます。\n    実は、最初に使用可能な日本のＳＩＭを先に入れてアクティブにすると書いてありました。使用可能なＳＩＭがないのでどうしていいのやらわからず、ＮＺのＳＩＭのみで試してました。\n\n    やはり日本のＳＩＭが必要なんですね。\n    ありがとうございました！！"
    supplement_comment = is_output_supplement_comment ? comment : ""
    is_output_url =  [false,false,false,false,true].rand
    url = is_output_url ? "http://www.ruby-lang.org/ja/man/html/Enumerable#{i}.html" : ""
	  file.puts <<-"EOF"
testu#{i}:
  id:                        #{i}
  content: |
    #{i}No.2です。

    ひょっとして使い方を間違ってるような感じがします。
    NZで契約したSIMだけで使おうとしていませんか？
    最初の１回だけは、通話可能なドコモSIMを挿さないとNZのSIMを使って通話できないと思います。
    ただし、海外でこれをやっても使えるかは試した事がないので判りません。
  supplement_comment: #{supplement_comment}
  thanks_comment: #{comment}
  url:                       #{url}
  kind:                      #{Answer::KINDS.keys.rand}
  confidence:                #{Answer::COMFIDENCES.keys.rand}
  character:                 #{Answer::CHARACTERS.keys.rand}
  receive_mail:              #{[true,false].rand}
  user_id:                   #{users.rand.id}
  question_id:               #{question_range.to_a.rand}
  created_at:                #{time.to_s(:db)}
  updated_at:                #{time.to_s(:db)}
EOF
  end
}






