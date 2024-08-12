class AdminController < ApplicationController
  before_action :authenticate_admin!

  def show
    @basketball_teams = BasketballTeam.all
  end
end
