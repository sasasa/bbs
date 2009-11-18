class AnswersController < ApplicationController
  # 上書き 1 @current_user
  before_filter :login_required, :except=>[:index, :show]
  # 上書き 2 @answer
  before_filter :check_valid_user, :except=>[:new, :create, :preview, :replay_edit, :replay_update, :replay_preview]
  # 末端カテゴリの質問に属する回答のみ閲覧、操作可能 4 @category
  before_filter :check_most_underlayer_category
  # カテゴリと質問の整合性チェック 5 @question
  before_filter :check_category_and_question_consistency
  # 質問と回答の整合性チェック 6 @answer
  before_filter :check_question_and_answer_consistency, :except=>[:new, :create, :preview]
  # 質問が締め切られているかチェック 7
  before_filter :check_question_closed, :except=>[:replay_edit, :replay_update, :replay_preview]
  # 回答にお礼や補足できるのは質問者のみ 8
  before_filter :check_question_owner, :only=>[:replay_edit, :replay_update, :replay_preview]
  # 自分で作った質問に自分で回答できないこと 9
  before_filter :check_no_question_owner, :only=>[:new, :create, :preview]

  # GET /categories/1/questions/1/answers/new
  def new
    @answer =
      if flash[:answer].blank?
        Answer.new.set_default_val
      else
        flash[:answer]
      end
    @question = Question.deep_include.find(params[:question_id])
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET POST /categories/1/questions/1/answers/new/preview
  def preview
    @question = Question.deep_include.find(params[:question_id])
    if request.post?
      @answer = Answer.new(params[:answer]).set_attrs(:user_id=>current_user.id, :question_id=>params[:question_id])
      flash[:answer] = @answer
      respond_to do |format|
        if @answer.valid?
          format.html # preview.html.erb
        else
          format.html { redirect_to new_category_question_answer_path(@category, @question) }
        end
      end
    elsif request.get? && !flash[:answer].blank?
      respond_to do |format|
        @answer = flash[:answer]
        flash[:answer] = @answer
        format.html # preview.html.erb
      end
    else
      raise "invalid preview action call"
    end
  end

  # GET /categories/1/questions/1/answers/1/edit
  def edit
  end

  # POST /categories/1/questions/1/answers
  def create
    @answer = Answer.new(params[:answer]).set_attrs(:user_id=>current_user.id, :question_id=>params[:question_id])

    respond_to do |format|
      if @answer.save
        flash[:notice] = "回答を作成しました。"#'Answer was successfully created.'
        format.html { redirect_to category_question_path(params[:category_id], params[:question_id])  }
      else
        @question = Question.deep_include.find(params[:question_id])
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /categories/1/questions/1/answers/1
  def update
    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        flash[:notice] = 'Answer was successfully updated.'
        format.html { redirect_to(@answer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1/questions/1/answers/1
  def destroy
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to(answers_url) }
      format.xml  { head :ok }
    end
  end
  
  # このアクションは回答者ではなく質問者がアクセスする
  # GET    /categories/1/questions/1/answers/1/replay_edit
  def replay_edit
    @answer = flash[:replay_answer] unless flash[:replay_answer].blank?
  end

  # このアクションは回答者ではなく質問者がアクセスする
  # GET PUT  /categories/1/questions/1/answers/1/replay_edit/replay_preview
  def replay_preview
    if request.put?
      @answer.supplement_comment = params[:answer][:supplement_comment]
      @answer.thanks_comment = params[:answer][:thanks_comment]
      flash[:replay_answer] = @answer
      respond_to do |format|
        if @answer.valid?
          format.html # replay_preview.html.erb
        else
          format.html { redirect_to replay_edit_category_question_answer_path(@category, @question, @answer) }
        end
      end
    elsif request.get? && !flash[:replay_answer].blank?
      respond_to do |format|
        @answer = flash[:replay_answer]
        flash[:replay_answer] = @answer
        format.html # replay_preview.html.erb
      end
    else
      raise "invalid replay_preview action call"
    end
  end

  # このアクションは回答者ではなく質問者がアクセスする
  # PUT    /categories/1/questions/1/answers/1/replay_update
  def replay_update
    @answer.supplement_comment = params[:answer][:supplement_comment]
    @answer.thanks_comment = params[:answer][:thanks_comment]
    respond_to do |format|
      if @answer.save
        flash[:notice] = "回答へのお礼と補足の登録をしました。"#'Answer was successfully updated.'
        format.html { redirect_to category_question_path(@category, @question) }
      else
        format.html { render :action => "replay_edit" }
      end
    end
  end

protected
  # オーバーライド 回答に権限があるユーザの操作かチェック 2 @answer
  def check_valid_user
    @answer = Answer.find(params[:id])
    raise "filter2" unless @answer.user_id == current_user.id
  end

  # オーバーライド パンくず作成 3 @category @topic_path @question
  def create_topic_path
    super
    @question ||= Question.find_by_id(params[:question_id])
    @topic_path << [@question.title, category_question_path(@category, @question)] if @question
    @topic_path <<
      case action_name
      when "replay_edit", "replay_update"
        [t("activerecord.models.answer") + t("Create thanks and supplement"), ""]
      when "replay_preview"
        [t("activerecord.models.answer") + t("Confirmation thanks and supplement"), ""]
      when "new", "create"
        [t("activerecord.models.answer") + t("Create"), ""]
      when "preview"
        [t("activerecord.models.answer") + t("Confirmation"), ""]
      end
  end

  # カテゴリと質問の整合性チェック 5 @question
  def check_category_and_question_consistency
    @question ||= Question.find(params[:question_id])
    raise "filter4" unless @question.category_id == @category.id
  end

  # 質問と回答の整合性チェック 6 @answer
  def check_question_and_answer_consistency
    @answer ||= Answer.find(params[:id])
    raise "filter5" unless @answer.question_id == @question.id
  end
  
  # 質問が締め切られているかチェック 7
  def check_question_closed
    @question ||= Question.find(params[:question_id])
    raise "filter6" if @question.is_closed
  end

  # 回答にお礼や補足できるのは質問者のみ 8
  def check_question_owner
    @question ||= Question.find(params[:question_id])
    redirect_to category_question_path(@category, @question) unless @question.user_id == current_user.id
  end

  # 自分で作った質問に自分で回答できないこと 9
  def check_no_question_owner
    @question ||= Question.find(params[:question_id])
    redirect_to category_question_path(@category, @question) if @question.user_id == current_user.id
  end
end
