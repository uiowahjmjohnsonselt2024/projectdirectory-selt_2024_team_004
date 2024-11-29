class WorldsController < ApplicationController
  before_action :set_current_user
  def landing
    puts params
    session[:world_id] = World.find_by(id: session[:world_id])
    puts session
    store
  end

  def new
    # Renders the character form
    @world_id = params[:world_id]
  end

  def index
    #@worlds parameter will be a list of all the world keys the current user has
    puts params
    puts current_user.name
    if current_user
      @user_worlds = current_user.user_worlds
    else
      flash[:alert] = 'Please log in to view your worlds.'
      redirect_to login_path
    end
  end

  def create
    puts 'Form submitted successfully!'
    @world = World.new(last_played: DateTime.now, progress: 0)
    return unless @world.save

    @world.update(world_name: "World #{@world.id}")
    UserWorld.create!(user: current_user, world: @world, user_role: user_roles, owner: true)
    flash[:notice] = 'World created successfully!'
    redirect_to worlds_path
    
  end

  def destroy
    puts params.inspect
    puts "UserWorld: #{@user_world.inspect}"
    @user_world = UserWorld.find_by(id: params[:id])
    puts @user_world
    @world = World.find_by(id: @user_world.world_id)
    if @user_world.owner
      UserWorld.where(world_id: @world.id).destroy_all
      @world.destroy
      flash[:notice] = "World '#{@world.world_id}' deleted."
    else
      @user_world.destroy
      flash[:notice] = "World '#{@world.world_id}' removed."
    end
    redirect_to worlds_path
  end

  def user_roles
    @gender = params[:gender]
    @preload = params[:preload]
    @role = params[:role]

    if @gender && @preload && @role
      @image_key = "#{@gender}_#{@preload}_#{@role}"
      @image_path = "/assets/images/#{@image_key}.png"
    else
      @image_path = '/assets/images/1_1_1.png'
    end
  end

  def start_game
    puts 'params'
    puts params

    @new_world = @world.

    redirect_to some_other_path, notice: 'Your adventure begins!'
  end

  def store
    @user = current_user
    @currency = @user.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@user)
  end

  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end
end
