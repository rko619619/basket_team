# app/controllers/players_controller.rb

class PlayersController < ApplicationController
  before_action :set_basketball_team
  before_action :set_player, only: [ :edit, :update, :destroy ]

  def new
    @player = @basketball_team.players.new
  end

  def create
    @player = @basketball_team.players.new(player_params)

    if @player.save
      redirect_to details_basketball_team_path(@basketball_team), notice: "Player created successfully."
    else
      redirect_to details_basketball_team_path(@basketball_team)
    end
  end

  def edit
    @basketball_team = BasketballTeam.find(params[:basketball_team_id])
    @player = @basketball_team.players.find(params[:id])
  end

  def update
    if @player.update(player_params)
      redirect_to details_basketball_team_path(@basketball_team), notice: "Player was successfully updated."
    else
      flash.now[:alert] = @player.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    @player = @basketball_team.players.find(params[:id])

    if @player.destroy
      redirect_to details_basketball_team_path(@basketball_team), notice: "Player was successfully deleted."
    else
      flash[:alert] = "Failed to delete player."
      redirect_to details_basketball_team_path(@basketball_team)
    end
  end
  private

  def set_basketball_team
    @basketball_team = BasketballTeam.find(params[:basketball_team_id])
  end

  def set_player
    @player = @basketball_team.players.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:last_name, :first_name, :birthdate, :license_number, :basketball_citizenship, :jersey_number, :photo, :citizenship_photo, :color)
  end
end
