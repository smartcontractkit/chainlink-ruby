class Assignment::RequestHandler

  attr_reader :assignment, :errors

  def self.perform(request)
    new(request).tap(&:perform)
  end

  def initialize(request)
    @request = request
    @coordinator = request.coordinator
    @body = request.body

    @assignment = request.build_assignment({
      end_at: parse_time(end_at),
    })
    @errors = []
  end

  def perform
    @subtasks = []
    @valid = true
    validate_subtasks

    set_assignment_attributes if valid?
  end

  def valid?
    valid
  end

  def errors
    assignment.errors
  end


  private

  attr_reader :body, :coordinator, :request, :subtasks, :valid

  def validate_subtasks
    subtask_params.each.with_index do |params, index|
      next unless params && type = params[:adapterType]
      subtask = build_subtask type, params, index

      if @valid = subtask.valid?
        subtasks << subtask
      else
        add_subtask_errors subtask
        subtasks.each(&:close_out!)
        break
      end
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

  def subtask_params
    request.subtask_params || [adapter_params]
  end

  def build_subtask(type, params, index)
    subtask_params = params[:adapterParams]

    assignment.subtasks.build({
      adapter: AdapterBuilder.perform(type, subtask_params),
      index: index,
      parameters: subtask_params,
      task_type: type,
    })
  end

  def add_subtask_errors(subtask)
    subtask.errors.full_messages.each do |error|
      assignment.errors[:base] << error
    end
  end

  def set_assignment_attributes
    assignment.assign_attributes({
      subtasks: subtasks,
      coordinator: coordinator,
      schedule_attributes: (schedule_params if schedule_params[:endAt]),
      scheduled_updates: (scheduled_updates if scheduled_updates.any?),
      skip_initial_snapshot: skip_initial_snapshot,
      start_at: parse_time(schedule_params[:startAt]),
    }.compact)
  end

end
