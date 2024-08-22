class DashboardController < ApplicationController
  before_action :authenticate_admin!

  def dashboard
    @basketball_teams = BasketballTeam.all
    @new_basketball_team = BasketballTeam.new
    @tournaments = Tournament.all
    @new_tournament = Tournament.new
  end
end
