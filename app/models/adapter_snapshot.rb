class AdapterSnapshot < ActiveRecord::Base

  belongs_to :adapter_assignment
  belongs_to :assignment_snapshot

  validates :adapter_assignment, presence: true, uniqueness: { scope: [:assignment_snapshot] }
  validates :assignment_snapshot, presence: true


  def details=(deets)
    self.details_json = (deets ? deets.to_json : nil)
    details
  end

  def details
    JSON.parse(details_json) if details_json.present?
  end

  def xid
    "#{assignment_snapshot.xid}=#{index}"
  end

  def index
    adapter_assignment.index
  end

  def adapter
    adapter_assignment.adapter
  end

  def assignment
    adapter_assignment.assignment
  end

  def response_errors
    details['errors'] if details.present?
  end

  def last?
    self == snapshot_peers.last
  end

  def start(params = {})
    handler.perform params.merge config: adapter_assignment.parameters
  end


  private

  def handler
    @handler ||= AdapterSnapshotHandler.new(self)
  end

  def snapshot_peers
    assignment_snapshot.adapter_snapshots
  end

end
