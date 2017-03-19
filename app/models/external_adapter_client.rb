class ExternalAdapterClient

  include HttpClient

  def initialize(validator)
    @validator = validator
  end

  def start_assignment(subtask)
    hashie_post(validator_url('/subtasks'), {
      data: subtask.parameters,
      endAt: subtask.end_at.to_i.to_s,
      taskType: subtask.task_type,
      xid: subtask.xid,
    })
  end

  def assignment_snapshot(snapshot, previous_snapshot = nil)
    subtask = snapshot.subtask
    hashie_post(validator_url("/subtasks/#{subtask.xid}/snapshots"), {
      details: previous_snapshot.try(:details),
      xid: snapshot.xid,
    }.compact)
  end

  def stop_assignment(subtask)
    hashie_delete(validator_url("/subtasks/#{subtask.xid}"))
  end


  private

  attr_reader :validator

  def validator_url(path)
    "#{validator.url}#{path}"
  end

  def http_client_auth_params
    {
      password: validator.password,
      username: validator.username,
    }
  end

end
