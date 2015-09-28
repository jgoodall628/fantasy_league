class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy, :add_player, :submit_team]

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @my_players = @team.player_list
    @players = @team.league.player_list.reject {|player_id| @my_players.include?(player_id)}

    @playernames = FantasyStat.last.find_player_names(@players)
    @player_roles = FantasyStat.last.find_player_roles(@players)
    @player_ppg = FantasyStat.last.find_player_ppgs(@players)
    @player_costs = FantasyStat.last.find_player_costs(@player_ppg)
    # @filter_term = params[:position]
    # @filter_term ||= "all"
    # @players = Player.where.not(id: @team.player_ids)
    # if @filter_term != 'all'
    #   @players = @players.where(position: @filter_term.downcase)
    # end

    @my_playernames = FantasyStat.last.find_my_player_names(@my_players)
    @my_player_roles = FantasyStat.last.find_player_roles(@my_players)
    @my_player_ppg = FantasyStat.last.find_player_ppgs(@my_players)
    @my_player_costs = FantasyStat.last.find_player_costs(@my_player_ppg)
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/1/edit
  def edit

    @player_id = params[:player_id].to_i
    @team.player_list.delete(@player_id)
    @team.save

    redirect_to @team
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.league.users.delete(current_user)
    @team.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end
  def submit_team
    @team.user = current_user
    @team.save
    current_user.balance -= @team.league.cost
    current_user.save
    redirect_to new_leagues_user_path(league_id: @team.league.id)

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(:name, :player1, :player2, :player3, :player4, :player5, :user)
  end
end
