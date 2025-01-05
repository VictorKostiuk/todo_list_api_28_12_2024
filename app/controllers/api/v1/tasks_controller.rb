class Api::V1::TasksController < ApplicationController
  before_action :set_task, only: %i[ show update destroy ]
  before_action :set_list, only: %i[ index create ]

  # GET /tasks
  def index
    if @list
      @tasks = @list.tasks
    else
      @tasks = Task.all
    end

    render json: @tasks
  end

  # GET /tasks/1
  def show
    render json: @task
  end

  # POST /tasks
  def create
    @task = Task.new( @list ? task_params.merge({list_id: @list.id}) : task_params)

    if @task.save
      UserMailer.task_email(current_user).deliver_later
      GoogleCalendarService.new(current_user).create_event(@task)
      render json: @task, status: :created
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      if params[:list_id]
        @list = List.find(params[:list_id])
      end
    end

    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a task of trusted parameters through.
    def task_params
      params.require(:task).permit(:name, :description, :deadline, :list_id)
    end
end
