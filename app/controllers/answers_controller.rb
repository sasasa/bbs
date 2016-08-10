class AnswersController < ApplicationController
  # fix bug

  # 上書き 2 @current_user
  before_filter :login_required, :except=>[:index, :show]
  # 上書き 4 @answer
  before_filter :check_valid_user, :except=>[:new, :create, :preview, :replay_edit, :replay_update, :replay_preview]
  # 末端カテゴリの質問に属する回答のみ閲覧、操作可能 6 @category
  before_filter :check_most_underlayer_category
  # カテゴリと質問の整合性チェック 7 @question
  before_filter :check_category_and_question_consistency
  # 質問と回答の整合性チェック 8 @answer
  before_filter :check_question_and_answer_consistency, :except=>[:new, :create, :preview]
  # 質問が締め切られているかチェック 9
  before_filter :check_question_closed, :except=>[:replay_edit, :replay_update, :replay_preview]
  # 回答にお礼や補足できるのは質問者のみ 10
  before_filter :check_question_owner, :only=>[:replay_edit, :replay_update, :replay_preview]
  # 自分で作った質問に自分で回答できないこと 11
  before_filter :check_no_question_owner, :only=>[:new, :create, :preview]

  # GET /categories/1/questions/1/answers/new
  def new
    @answer = flash[:answer] ? flash[:answer] : Answer.new.set_default_val
    @question = Question.deep_include.find(params[:question_id])
  end

  # GET POST /categories/1/questions/1/answers/new/preview
  def preview
    @question = Question.deep_include.find(params[:question_id])
    if request.post?
      flash[:answer] = @answer = Answer.new(params[:answer]).set_attrs(:user_id=>current_user.id, :question_id=>params[:question_id])
        if @answer.valid?
          #
        else
          redirect_to new_category_question_answer_path(@category, @question)
        end
    elsif request.get? && !flash[:answer].blank?
      flash[:answer] = @answer = flash[:answer] #flashの寿命をのばす
    else
      redirect_to new_category_question_answer_path(@category, @question)
    end
  end

  # POST /categories/1/questions/1/answers
  def create
    @answer = Answer.new(params[:answer]).set_attrs(:user_id=>current_user.id, :question_id=>params[:question_id])
    if @answer.save
      #ここでキャッシュを失効させる
      Question.expire_cache("Question.cache_paginate_order_recent(#{@category.id},#{session[:page]})")
      Question.expire_cache("Question.cache_deep_include_find(#{@question.id})")
      
      flash[:notice] = "回答を作成しました。"#'Answer was successfully created.'
      redirect_to category_question_path(params[:category_id], params[:question_id])
    else
      redirect_to new_category_question_answer_path(@category, @question)
    end
  end

  # GET /categories/1/questions/1/answers/1/edit
  def edit
  end

  # PUT /categories/1/questions/1/answers/1
  def update
    if @answer.update_attributes(params[:answer])
      flash[:notice] = 'Answer was successfully updated.'
      redirect_to(@answer)
    else
      render "edit"
    end
  end

  # DELETE /categories/1/questions/1/answers/1
  def destroy
    @answer.destroy
    redirect_to(answers_url)
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
      if @answer.valid?
        #
      else
        redirect_to replay_edit_category_question_answer_path(@category, @question, @answer)
      end
    elsif request.get? && !flash[:replay_answer].blank?
      flash[:replay_answer] = @answer = flash[:replay_answer] #flashの寿命をのばす
    else
      redirect_to replay_edit_category_question_answer_path(@category, @question, @answer)
    end
  end

  # このアクションは回答者ではなく質問者がアクセスする
  # PUT    /categories/1/questions/1/answers/1/replay_update
  def replay_update
    @answer.supplement_comment = params[:answer][:supplement_comment]
    @answer.thanks_comment = params[:answer][:thanks_comment]
    if @answer.save
      flash[:notice] = "回答へのお礼と補足の登録をしました。"#'Answer was successfully updated.'
      redirect_to category_question_path(@category, @question)
    else
      redirect_to replay_edit_category_question_answer_path(@category, @question, @answer)
    end
  end

protected
  # オーバーライド 回答に権限があるユーザの操作かチェック 4 @answer
  def check_valid_user
    logger.debug "filter4 check_valid_user => @answer"
    @answer ||= Answer.cache_find(params[:id])
    raise "filter4" unless ret = (@answer.user_id == current_user.id)
    ret
  end
  memoize :check_valid_user

  # オーバーライド パンくず作成 5 @category @topic_path @question
  def create_topic_path
    logger.debug "filter5 create_topic_path => @category @topic_path @question"
    super
    @question ||= Question.cache_find(params[:question_id])
    @topic_path << [@question.title, category_question_path(@category, @question)]
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

  # カテゴリと質問の整合性チェック 7 @question
  def check_category_and_question_consistency
    logger.debug "filter7 check_category_and_question_consistency => @question"
    @question ||= Question.cache_find(params[:question_id])
    raise "filter7" unless @question.category_id == @category.id
  end

  # 質問と回答の整合性チェック 8 @answer
  def check_question_and_answer_consistency
    logger.debug "filter8 check_question_and_answer_consistency => @answer"
    @answer ||= Answer.cache_find(params[:id])
    raise "filter8" unless @answer.question_id == @question.id
  end
  
  # 質問が締め切られているかチェック 9
  def check_question_closed
    logger.debug "filter9 check_question_closed => @question"
    @question ||= Question.cache_find(params[:question_id])
    raise "filter9" if @question.is_closed
  end

  # 回答にお礼や補足できるのは質問者のみ 10
  def check_question_owner
    logger.debug "filter10 check_question_owner => @question"
    @question ||= Question.cache_find(params[:question_id])
    redirect_to category_question_path(@category, @question) unless @question.user_id == current_user.id
  end

  # 自分で作った質問に自分で回答できないこと 11
  def check_no_question_owner
    logger.debug "filter11 check_no_question_owner => @question"
    @question ||= Question.cache_find(params[:question_id])
    redirect_to category_question_path(@category, @question) if @question.user_id == current_user.id
  end
end
