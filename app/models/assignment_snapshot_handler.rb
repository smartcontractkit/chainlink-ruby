class AssignmentSnapshotHandler

  def self.start(id)
    snapshot = AssignmentSnapshot.find(id)
    new(snapshot).start
  end

  def initialize(snapshot)
    @snapshot = snapshot
    @adapter_snapshots = snapshot.adapter_snapshots
  end

  def start
    latest_unchecked.start
  end

  def adapter_response(adapter_snapshot)
    return unless adapter_snapshot.fulfilled?

    if adapter_snapshot.response_errors.present?
      handle_adapter_errors adapter_snapshot
    else
      move_assignment_forward_with adapter_snapshot
    end
  end


  private

  attr_reader :adapter_snapshots, :snapshot

  def latest_unchecked
    snapshot.current_adapter_snapshot
  end

  def assignment
    snapshot.assignment
  end

  def handle_adapter_errors(adapter_snapshot)
    snapshot.update_attributes({
      progress: AssignmentSnapshot::FAILED,
      details: adapter_snapshot.details
    })

    Notification.delay.snapshot_failure assignment, adapter_snapshot.response_errors
  end

  def move_assignment_forward_with(adapter_snapshot)
    if adapter_snapshot.last?
      complete_assignment_snapshot adapter_snapshot
    else
      move_to_next_adapter adapter_snapshot
    end
  end

  def complete_assignment_snapshot(adapter_snapshot)
    snapshot.update_attributes({
      description: adapter_snapshot.description,
      description_url: adapter_snapshot.description_url,
      details: adapter_snapshot.details,
      fulfilled: true,
      progress: AssignmentSnapshot::COMPLETED,
      summary: adapter_snapshot.summary,
      value: adapter_snapshot.value,
    })

    update_assignment_status adapter_snapshot.status
  end

  def move_to_next_adapter(adapter_snapshot)
    next_adapter_snapshot = snapshot.next_adapter_snapshot
    snapshot.update_attributes({
      adapter_index: next_adapter_snapshot.index,
    })
    next_adapter_snapshot.start adapter_snapshot
  end

  def update_assignment_status(new_status)
    assignment.update_status(new_status) if new_status.present?
  end

end
