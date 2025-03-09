class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[update destroy]

  def index
    @tasks = current_user.tasks.includes(:subtasks, :tags)
    render json: TaskSerializer.new(@tasks), status: :ok
  end

  def show
    task = current_user.tasks.find(params[:id])
    render json: TaskSerializer.new(task), status: :ok
  end

  def create
    task = current_user.tasks.new(task_params)

    if task.save!
      render json: TaskSerializer.new(task), status: :created
    else
      render json: {
        error: task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      @task.reload
      render json: TaskSerializer.new(@task), status: :ok
    else
      render json: {
        error: @task.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @task.destroy!
      render status: :ok
    else
      render json: {
        error: "Could not delete this task: #{@task.errors.full_messages}"
      }, status: 409 # Replace this error code in the future for a more appropriate on
    end
  end

  private
    def task_params
      params.require(:task).permit(
        :id, :name, :description, :deadline, :priority_level,
        :expected_completion_time, :time_spent, :subject_id, tag_ids: [],
        subtasks_attributes: [ :id, :name, :new_name, :subtask_type, :description, :completed, :position, :_destroy ] # Allow nested subtasks
      )
    end

    def set_task
      params.require(:task).require(:id)
      @task = current_user.tasks.find(task_params[:id])

      unless @task
        render json: {
          error: "Couldn't find task!"
        }, status: :not_found
      end
    end
end
