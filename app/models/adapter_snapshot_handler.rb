class AdapterSnapshotHandler

  def initialize(snapshot)
    @snapshot = snapshot
    @adapter = snapshot.adapter
    @assignment = snapshot.assignment
  end

  def perform
    if response.present? && response.errors.blank?
      parse_adapter_response response
      snapshot.save
    else
      Notification.delay.snapshot_failure assignment, response.try(:errors)
    end
  end


  private

  attr_reader :adapter, :assignment, :snapshot

  def response
    @response ||= adapter.get_status(snapshot)
  end

  def parse_adapter_response(response)
    return unless response.fulfilled

    snapshot.fulfilled = true
    snapshot.summary ||= response.summary
    snapshot.value = response.value
    snapshot.details = response.details
    snapshot.description = response.description
    snapshot.description_url = response.description_url
  end

end
