class SubmissionsController < ApplicationController
  before_action :require_login
  before_action :set_lobby

  def create
    word = params[:word].to_s.strip

    if word.blank?
      error_message = "Please enter a word."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "submission_area",
            partial: "lobbies/submission_form",
            locals: { lobby: @lobby, alert: error_message }
          ), status: :unprocessable_entity
        end
        format.html { redirect_to @lobby, alert: error_message }
      end
      return
    end

    begin
      ActiveRecord::Base.transaction do
        if current_user.submissions.where(lobby_id: @lobby.id).count >= 3
          raise "Limit reached"
        end

        @submission = @lobby.submissions.create!(user: current_user, word: word)
        ActivityLog.create!(user: current_user, action: "submitted_word")
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "submission_area",
            partial: "lobbies/submission_form",
            locals: { lobby: @lobby, notice: "Word '#{word}' successfully submitted!" }
          )
        end
        format.html { redirect_to @lobby, notice: "Word '#{word}' successfully submitted!" }
      end
    rescue RuntimeError => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "submission_area",
            partial: "lobbies/submission_form",
            locals: { lobby: @lobby, alert: "Limit reached: Maximum 3 words per question." }
          ), status: :unprocessable_entity
        end
        format.html { redirect_to @lobby, alert: "Limit reached: Maximum 3 words per question." }
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "submission_area",
            partial: "lobbies/submission_form",
            locals: { lobby: @lobby, alert: e.record.errors.full_messages.to_sentence }
          ), status: :unprocessable_entity
        end
        format.html { redirect_to @lobby, alert: e.record.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_lobby
    @lobby = Lobby.find(params[:lobby_id])
  end
end
