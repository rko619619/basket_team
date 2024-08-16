# app/controllers/players_controller.rb

class CoachesController < ApplicationController
  before_action :set_basketball_team
  before_action :set_coach, only: [ :edit, :update, :destroy ]

  def new
    @coach = @basketball_team.coaches.new
  end

  def create
    @coach = @basketball_team.coaches.new(coach_params)

    if @coach.save
      redirect_to details_basketball_team_path(@basketball_team), notice: "Player created successfully."
    else
      redirect_to details_basketball_team_path(@basketball_team)
    end
  end

  def edit
    @basketball_team = BasketballTeam.find(params[:basketball_team_id])
    @coach = @basketball_team.coaches.find(params[:id])
  end

  def update
    if @coach.update(coach_params)
      redirect_to details_basketball_team_path(@basketball_team), notice: "Player was successfully updated."
    else
      flash.now[:alert] = @coach.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    @coach = @basketball_team.coaches.find(params[:id])

    if @coach.destroy
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

  def set_coach
    @coach = @basketball_team.coaches.find(params[:id])
  end

  def coach_params
    params.require(:coach).permit(:last_name, :first_name, :date_of_birth, :license_number, :position)
  end
end

