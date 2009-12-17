#環境によらず共通の設定項目

# mailをTLS送信できるようにする
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
# eruby関連のログを出さない
Erubis::Helpers::RailsHelper.show_src = false


#キャッシュストア設定
#ActionController::Base.cache_store = :mem_cache_store, "localhost"
