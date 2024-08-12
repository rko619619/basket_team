# app/controllers/basketball_teams_controller.rb
class BasketballTeamsController < ApplicationController
  before_action :set_basketball_team, only: %i[show edit update destroy]

  def index
    @basketball_teams = BasketballTeam.all
  end

  def show
  end

  def new
    @basketball_team = BasketballTeam.new
  end

  def create
    @basketball_team = BasketballTeam.new(basketball_team_params)
    if @basketball_team.save
      redirect_to @basketball_team, notice: 'Basketball team was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @basketball_team.update(basketball_team_params)
      redirect_to @basketball_team, notice: 'Basketball team was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @basketball_team.destroy
    redirect_to basketball_teams_url, notice: 'Basketball team was successfully destroyed.'
  end

  private

  def set_basketball_team
    @basketball_team = BasketballTeam.find(params[:id])
  end

  def basketball_team_params
    params.require(:basketball_team).permit(:name, :city, :championships)
  end
end
