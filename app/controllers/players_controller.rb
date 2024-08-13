# app/controllers/players_controller.rb

class PlayersController < ApplicationController
  def new
    @basketball_team = BasketballTeam.find(params[:basketball_team_id])
    @player = @basketball_team.players.new
  end

  def create
    @basketball_team = BasketballTeam.find(params[:basketball_team_id])
    @player = @basketball_team.players.new(player_params)

    if @player.save
      redirect_to details_basketball_team_path(@basketball_team), notice: 'Player created successfully.'
    else
      redirect_to details_basketball_team_path(@basketball_team)
    end
  end

  private

  def player_params
    params.require(:player).permit(:last_name, :first_name, :birthdate, :license_number, :basketball_citizenship, :jersey_number, :photo, :citizenship_photo)
  end
end
