class QuestionsController < ApplicationController
  # 上書き 1 @current_user
  before_filter :login_required, :except=>[:index, :show]
  # 上書き 2 @question
  before_filter :check_valid_user, :except=>[:index, :show, :new, :create, :preview]
  # 末端カテゴリの質問のみ閲覧、操作可能 4 @category
  before_filter :check_most_underlayer_category
  # カテゴリと質問の整合性チェック 5 @question
  before_filter :check_category_and_question_consistency, :except=>[:index, :new, :create, :preview]
  
  # GET categories/1/questions
  def index
    @category ||= Category.find(params[:category_id])
    @questions = Question.relate(@category).include.order_recent.paginate(:page => params[:page], :per_page => 5)
  end

  # GET categories/1/questions/1
  def show
    @question = Question.deep_include.find(params[:id])
  end

  # GET categories/1/questions/new
  def new
    @question = flash[:question] ? flash[:question] : Question.new.set_default_val
  end

  # GET POST categories/1/questions/new/preview
  def preview
    if request.post?
      flash[:question] = @question = Question.new(params[:question]).set_attrs(:user_id=>current_user.id, :category_id=>@category.id)
      if @question.valid?
        #
      else
        redirect_to new_category_question_path(@category)
      end
    elsif request.get? && !flash[:question].blank?
      flash[:question] = @question = flash[:question] #flashの寿命をのばす
    else
      redirect_to new_category_question_path(@category)
    end
  end

  # GET /categories/1/questions/1/edit
  def edit
  end

  # POST /categories/1/questions
  def create
    @question = Question.new(params[:question]).set_attrs(:user_id=>current_user.id, :category_id=>@category.id)

    if @question.save
      flash[:notice] = "質問を作成しました。"#'Question was successfully created.'
      redirect_to category_question_path(@category, @question)
    else
      render "new"
    end
  end

  # 締め切りの変更
  # PUT /categories/1/questions/1
  def update
    if @question.update_attributes(params[:question])
      flash[:notice] = "この質問に対する回答は締め切られました。"#'Question was successfully updated.'
    end
    redirect_to category_question_path(params[:category_id], @question)
  end

  # DELETE /categories/1/questions/1
  def destroy
    @question.destroy
    redirect_to(questions_url)
  end

protected
  # オーバーライド 質問に権限があるユーザの操作かチェック 2 @question
  def check_valid_user
    @question = Question.find(params[:id])
    raise "filter2" unless @question.user_id == current_user.id
  end

  # オーバーライド パンくず作成 3 @category @topic_path @question
  def create_topic_path
    super
    @question ||= Question.find_by_id(params[:id]) if params[:id]
    @topic_path <<
      case action_name
      when "show"
        [t("activerecord.models.question") + " (#{@question.title})", ""]
      when "create", "new"
        [t("activerecord.models.question") + t("Create"), ""]
      when "preview"
        [t("activerecord.models.question") + t("Confirmation"), ""]
      end
  end

  # カテゴリと質問の整合性チェック 5 @question
  def check_category_and_question_consistency
    @question ||= Question.find(params[:id])
    raise "filter4" unless @question.category_id == @category.id
  end
end
