require 'pry'

# app/controllers/basketball_teams_controller.rb
class BasketballTeamsController < ApplicationController
  before_action :set_basketball_team, only: %i[show edit update destroy details create_player]

  def export_pdf
    team = BasketballTeam.find(params[:id])
    tournament = Tournament.find(params[:tournament_id]) # Теперь `tournament_id` будет корректно передаваться

    pdf = PdfGenerator.new(team, tournament).generate_pdf

    send_data pdf, filename: "#{team.name}_#{Time.now.strftime('%Y%m%d')}.pdf", type: 'application/pdf'
  end

  def index
    @basketball_teams = BasketballTeam.all
  end

  def show
    redirect_to dashboard_path
  end

  def details
    @basketball_team = BasketballTeam.find(params[:id])
    @players = @basketball_team.players
    @player = Player.new
    @coaches = @basketball_team.coaches
    @coach = Coach.new
  end

  def create_player
    @player = @basketball_team.players.build(player_params)
    if @player.save
      redirect_to details_basketball_team_path(@basketball_team), notice: "Игрок был добавлен."
    else
      @players = @basketball_team.players
      render :details
    end
  end

  def create_coach
    @coach = @basketball_team.coaches.build(coach_params)
    if @coach.save
      redirect_to details_basketball_team_path(@basketball_team), notice: "Тренер был добавлен."
    else
      @coaches = @basketball_team.coaches
      render :details
    end
  end

  def new
    @basketball_team = BasketballTeam.new
  end

  def create
    @basketball_team = BasketballTeam.new(basketball_team_params)
    if @basketball_team.save
      redirect_to dashboard_path, notice: "Команда успешно создана."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    respond_to do |format|
      format.html # для обычного HTML
      format.turbo_stream # для Turbo Frames
    end
  end

  def update
    if @basketball_team.update(basketball_team_params)
      respond_to do |format|
        format.html { redirect_to dashboard_path, notice: "Команда успешно обновлена." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.turbo_stream
      end
    end
  end

  def destroy
    @basketball_team = BasketballTeam.find(params[:id])
    @basketball_team.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "Basketball team was successfully deleted." }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@basketball_team) }
    end
  end

  private

  def set_basketball_team
    @basketball_team = BasketballTeam.find(params[:id])
  end

  def basketball_team_params
    params.require(:basketball_team).permit(:name, :description)
  end

  def player_params
    params.require(:player).permit(:last_name, :first_name, :birthdate, :license_number, :jersey_number, :photo, :citizenship_photo)
  end

  def coach_params
    params.require(:coach).permit(:first_name, :last_name, :date_of_birth, :license_number, :position)
  end
end
