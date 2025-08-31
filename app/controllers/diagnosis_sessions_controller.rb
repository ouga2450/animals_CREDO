class DiagnosisSessionsController < ApplicationController
    before_action :find_session, only: [:show, :answer, :result]
  # 診断開始画面
  def new; end

  # セッション作成
  def create
    @session = DiagnosisSession.new

    if @session.save
      redirect_to diagnosis_session_path(@session)
    else
      flash.now[:alert] = "セッション作成に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  # 質問表示
  def show
    if @session.completed?
      redirect_to result_diagnosis_session_path(@session)
    else
      @current_question = @session.current_question
      @question_number = @session.current_question_number
      @total_questions = DiagnosisSession::TOTAL_QUESTIONS
    end
  end

  # 質問回答処理
  def answer
    if @session.process_answer(params[:option])
      if @session.completed?
        redirect_to result_diagnosis_session_path(@session)
      else
        redirect_to diagnosis_session_path(@session)
      end
    else
      flash.now[:alert] = "選択肢を選んでください"
      redirect_to diagnosis_session_path(@session)
    end
  end

  # 結果表示
  def result
    unless @session.completed?
      return redirect_to diagnosis_session_path(@session)
    end

    @animal_key = @session.result_animal_type
    @animal     = DiagnosisSession::ANIMAL_CREDO_MAPPING[@animal_key.to_sym]
  end

  private

  def find_session
    @session = DiagnosisSession.find_by!(session_token: params[:token])
  end
end
