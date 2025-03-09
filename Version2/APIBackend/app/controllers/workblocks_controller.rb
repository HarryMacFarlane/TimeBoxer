class WorkblocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workblock, only: %i[update destroy]

  def index
    @workblocks = current_user.workblocks.includes(:task_sessions)
    render json: WorkblockSerializer.new(@workblocks), status: :ok
  end

  def show
    workblock = current_user.workblocks.find(params[:id])
    unless workblock
      render json: {
        error: "Could not find specified workblock for id: #{params[:id]}"
      }, status: :not_found
    end
    render json: WorkblockSerializer.new(workblock), status: :ok
  end

  def create
    # Ensure ids cannot be manually assigned to ensure backend takes care of id numbers uniquely!
    createParams = workblock_params.except(:id)
    workblock = current_user.workblocks.new(createParams)

    if workblock.save
      render json: WorkblockSerializer.new(workblock), status: :created
    else
      render json: {
        error: workblock.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @workblock.update(workblock_params)
      render json: WorkblockSerializer.new(@workblock), status: :ok
    else
      render json: {
        error: @workblock.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @workblock.destroy
      render status: :ok
    else
      render json: {
        error: "Could not delete this workblock: #{@workblock.errors.full_messages}"
      }, status: :conflict
    end
  end

  private
    def workblock_params
      params.require(:workblock).permit(
        :id, :duration, :timestamp, :completed, task_sessions_attributes: [ :id, :start_time, :end_time, :subtask_id, :duration, :_destroy ],
      )
    end

    def set_workblock
      params.require(:workblock).require(:id)
      @workblock = current_user.workblocks.find(workblock_params[:id])

      unless @workblock
        render json: {
          error: "Couldn't find workblock!"
        }, status: :not_found
      end
    end
end
