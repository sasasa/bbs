class CategoriesController < ApplicationController
  # 上書き 1 @current_user
  before_filter :login_required, :except=>[:index, :show]
  # GET /categories
  def index
    @root_categories_every_col = Category.root_categories_every_col
    respond_to do |format|
      format.html
    end
  end

  # GET /categories/1
  def show
    @category = Category.include.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end

# 操作権限チェック 2
protected
  def check_valid_user
  end
end
