class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:edit, :update, :destroy]

  def create
    @tournament = Tournament.new(tournament_params)
    if @tournament.save
      redirect_to dashboard_path, notice: 'Турнир успешно создан.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @tournament.update(tournament_params)
      redirect_to dashboard_path, notice: 'Турнир успешно обновлен.'
    else
      render :edit
    end
  end

  def destroy
    @tournament.destroy
    redirect_to dashboard_path, notice: 'Турнир успешно удален.'
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name)
  end
end
