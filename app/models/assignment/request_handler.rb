class Assignment::RequestHandler

  def self.perform(request)
    new(request).perform
  end

  def initialize(request)
    @request = request
    @coordinator = request.coordinator
    @body = request.body
  end

  def perform
    @assignment ||= request.build_assignment({
      subtasks: subtasks,
      coordinator: coordinator,
      end_at: parse_time(end_at),
      schedule_attributes: (schedule_params if schedule_params[:endAt]),
      scheduled_updates: (scheduled_updates if scheduled_updates.any?),
      skip_initial_snapshot: skip_initial_snapshot,
      start_at: parse_time(schedule_params[:startAt]),
    }.compact)
  end


  private

  attr_reader :assignment, :body, :coordinator, :request

  def subtasks
    @subtasks ||= request.subtask_params.map.with_index do |params, index|
      next unless params && type = params[:adapterType]
      subtask_params = params[:adapterParams] || adapter_params

      Subtask.new({
        adapter: AdapterBuilder.perform(type, subtask_params),
        index: index,
        parameters: subtask_params,
        task_type: type,
      })
    end
  end

  def adapter_params
    request.assignment_params[:adapterParams]
  end

  def end_at
    return @end_at if @end_at.present?
    times = Array.wrap(schedule_params[:runAt])
    times += [schedule_params[:endAt]]
    @end_at = times.compact.map(&:to_i).max
  end

  def parse_time(time)
    Time.at time.to_i if time.present?
  end

  def schedule_params
    return @schedule_params if @scheduled_params.present?

    @schedule_params = body[:schedule]
    @schedule_params ||= body[:assignment] && body[:assignment][:schedule]
    @schedule_params ||= {minute: '0', hour: '0'}
  end

  def scheduled_updates
    @scheduled_updates ||= Array.wrap(schedule_params[:runAt]).compact.map do |time|
      Assignment::ScheduledUpdate.new run_at: parse_time(time)
    end
  end

  def skip_initial_snapshot
    request.assignment_params[:skipInitialSnapshot]
  end

end
