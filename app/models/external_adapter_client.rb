class ExternalAdapterClient

  include HttpClient

  def initialize(validator)
    @validator = validator
  end

  def start_assignment(assignment)
    hashie_post(validator_url('/assignments'), {
      data: assignment.parameters,
      end_at: assignment.end_at.to_i.to_s,
      xid: assignment.xid,
    })
  end

  def assignment_snapshot(snapshot)
    assignment = snapshot.assignment
    hashie_post(validator_url("/assignments/#{assignment.xid}/snapshots"), {
      xid: snapshot.xid
    })
  end

  def stop_assignment(assignment)
    hashie_delete(validator_url("/assignments/#{assignment.xid}"))
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
