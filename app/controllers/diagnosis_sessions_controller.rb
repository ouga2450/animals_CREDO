class DiagnosisSessionsController < ApplicationController
    before_action :find_session, only: [:show, :answer, :result]

  # 診断開始画面
  def new; end

  # セッション作成
  def create
    @session = DiagnosisSession.new

    if @session.save
      redirect_to diagnosis_session_path(@session.session_token)
    else
      render :new
    end
  end

  # 質問表示
  def show
    if @session.completed?
      redirect_to result_diagnosis_session_path(@session.session_token)
    else
      @current_question = @session.current_question
      @question_number = @session.current_question_number
      @total_questions = DiagnosisSession::TOTAL_QUESTIONS
    end
  end

  # 質問回答処理
  def answer
  end

  # 結果表示
  def result
  end

  private

  def find_session

  end
end
