#libの中を読み込む
require 'i18n_label_helper'
require 'extend_string'
require 'modify_field_error'
require 'modify_submit_tag_helper'
require 'modify_input_tag_helper'
require 'extend_active_record_base'

#mailをTLS送信できるようにする
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
