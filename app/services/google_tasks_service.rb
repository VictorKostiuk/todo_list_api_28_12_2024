require 'google/apis/tasks_v1'
require 'googleauth'

class GoogleTasksService
  APPLICATION_NAME = 'MyAPP'
  SCOPE = Google::Apis::TasksV1::AUTH_TASKS

  def initialize(user)
    @user = user
    @tasks_service = Google::Apis::TasksV1::TasksService.new
    @tasks_service.client_options.application_name = APPLICATION_NAME
    @tasks_service.authorization = user.google_credentials
  end

  def create_task_list(list)
    new_task_list = Google::Apis::TasksV1::TaskList.new(
      title: list.name
    )

    task_list = @tasks_service.insert_tasklist(new_task_list)
    puts "Created Task List: #{task_list.title}, ID: #{task_list.id}"
    task_list
  end

  def create_task(task)
    list = List.find(task.list_id)
    task_list_id = list.google_tasks_list_id.nil? ? 'T2lOY1RULWo5M0JiZl9VTQ' : list.google_tasks_list_id

    google_task = Google::Apis::TasksV1::Task.new(
      title: task.name,
      notes: task.description,
      due: task.deadline.iso8601
    )

    @tasks_service.insert_task(task_list_id, google_task)
  end

  def update_task(google_list_id, google_task_id, attributes)
    task = @tasks_service.get_task(google_list_id, google_task_id)

    task.title = attributes[:name] if attributes[:name]
    task.notes = attributes[:description] if attributes[:description]
    task.due = attributes[:deadline].iso8601 if attributes[:deadline]

    @tasks_service.update_task(google_list_id, google_task_id, task)
  end

  def delete_task(list ,task_id)
    @tasks_service.delete_task(list.google_tasks_list_id, task_id)
  end
end

