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

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET categories/1/questions/1
  def show
    @question = Question.deep_include.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET categories/1/questions/new
  def new
    @question =
      if flash[:question].blank?
        Question.new.set_default_val
      else
        flash[:question]
      end
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET POST categories/1/questions/new/preview
  def preview
    if request.post?
      @question = Question.new(params[:question]).set_attrs(:user_id=>current_user.id, :category_id=>@category.id)
      flash[:question] = @question
      respond_to do |format|
        if @question.valid?
          format.html # preview.html.erb
        else
          format.html { redirect_to new_category_question_path(@category) }
        end
      end
    elsif request.get? && !flash[:question].blank?
      respond_to do |format|
        @question = flash[:question]
        flash[:question] = @question
        format.html # preview.html.erb
      end
    else
      raise "invalid preview action call"
    end
  end

  # GET /categories/1/questions/1/edit
  def edit
  end

  # POST /categories/1/questions
  def create
    @question = Question.new(params[:question]).set_attrs(:user_id=>current_user.id, :category_id=>@category.id)

    respond_to do |format|
      if @question.save
        flash[:notice] = "質問を作成しました。"#'Question was successfully created.'
        format.html { redirect_to category_question_path(@category, @question) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # 締め切りの変更
  # PUT /categories/1/questions/1
  def update
    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = "この質問に対する回答は締め切られました。"#'Question was successfully updated.'
      end
      format.html { redirect_to category_question_path(params[:category_id], @question) }
    end
  end

  # DELETE /categories/1/questions/1
  def destroy
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
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
