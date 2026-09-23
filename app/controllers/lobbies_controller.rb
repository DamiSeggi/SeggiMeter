class LobbiesController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [ :new, :create, :edit, :update, :destroy, :lock, :unlock ]
  before_action :set_lobby, only: [ :show, :edit, :update, :destroy, :lock, :unlock ]

  def index
    @lobbies = Lobby.includes(:user, :submissions).order(created_at: :desc)
  end

  def show
    @submission = Submission.new
    @user_submission_count = current_user.submission_count_for(@lobby)
    @can_submit = current_user.can_submit_to?(@lobby)
  end

  def new
    @lobby = current_user.lobbies.build
  end

  def create
    @lobby = current_user.lobbies.build(lobby_params)

    if @lobby.save
      ActivityLog.create!(user: current_user, action: "lobby_created")
      redirect_to @lobby, notice: "Lobby successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if @lobby.locked? && !@lobby.locked_by?(current_user)
      redirect_to @lobby, alert: "Lobby is currently being edited by #{@lobby.locked_by.name}."
      return
    end

    @lobby.lock_for!(current_user)
  end

  def update
    @lobby.with_lock do
      if @lobby.locked? && !@lobby.locked_by?(current_user)
        redirect_to @lobby, alert: "Lobby is currently being edited by #{@lobby.locked_by.name}."
        return
      end

      if @lobby.update(title: lobby_params[:title], locked_by: nil)
        ActivityLog.create!(user: current_user, action: "lobby_updated")
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("lobby_header", partial: "lobbies/title", locals: { lobby: @lobby }) }
          format.html { redirect_to @lobby, notice: "Lobby was successfully updated." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("lobby_header", partial: "lobbies/edit_title_form", locals: { lobby: @lobby }), status: :unprocessable_entity }
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  end

  def lock
    if @lobby.locked? && !@lobby.locked_by?(current_user)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("lobby_header", partial: "lobbies/title", locals: { lobby: @lobby, locked_by_other: true }) }
        format.html { redirect_to @lobby, alert: "Lobby is currently being edited by #{@lobby.locked_by.name}." }
      end
    else
      @lobby.lock_for!(current_user)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("lobby_header", partial: "lobbies/edit_title_form", locals: { lobby: @lobby }) }
        format.html { redirect_to edit_lobby_path(@lobby) }
      end
    end
  end

  def unlock
    @lobby.unlock! if @lobby.locked_by?(current_user)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("lobby_header", partial: "lobbies/title", locals: { lobby: @lobby }) }
      format.html { redirect_to @lobby }
    end
  end

  def destroy
    @lobby.destroy
    ActivityLog.create!(user: current_user, action: "lobby_deleted")
    redirect_to lobbies_path, notice: "Lobby was deleted."
  end

  private

  def set_lobby
    @lobby = Lobby.find(params[:id])
  end

  def lobby_params
    params.require(:lobby).permit(:title)
  end
end
