#環境によらず共通の設定項目

# mailをTLS送信できるようにする
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
# eruby関連のログを出さない
Erubis::Helpers::RailsHelper.show_src = false

#ActionMailerの中で使用するURLメソッドにホスト名を与える必要がある
HOSTNAME = `hostname`.chomp
