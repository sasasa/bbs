class CategoriesController < ApplicationController
  # 上書き 2 @current_user
  before_filter :login_required, :except=>[:index, :show]
  # GET /categories
  def index
    @root_categories_every_col = Category.cache_root_categories_every_col
  end

  # GET /categories/1
  def show
    @category = Category.cache_include_find(params[:id])
  end

# 操作権限チェック 4
protected
  def check_valid_user
    logger.debug "filter4 check_valid_user"
  end
end
