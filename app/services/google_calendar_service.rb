require 'google/apis/calendar_v3'
require 'googleauth'

class GoogleCalendarService
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'MyAPP'
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

  def initialize(user)
    @user = user
    @calendar_service = Google::Apis::CalendarV3::CalendarService.new
    @calendar_service.client_options.application_name = APPLICATION_NAME
    @calendar_service.authorization = user.google_credentials
  end

  def create_event(task)
    event = Google::Apis::CalendarV3::Event.new(
      summary: task.name,
      description: task.description,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: DateTime.now.iso8601,
        time_zone: 'UTC'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: task.deadline.iso8601,
        time_zone: 'UTC'
      )
    )
    @calendar_service.insert_event('primary', event)
  end
end
