class AdapterSnapshot < ActiveRecord::Base

  belongs_to :subtask
  belongs_to :assignment_snapshot

  validates :subtask, presence: true, uniqueness: { scope: [:assignment_snapshot] }
  validates :assignment_snapshot, presence: true

  before_create :set_up


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
    subtask.index
  end

  def adapter
    subtask.adapter
  end

  def assignment
    subtask.assignment
  end

  def response_errors
    details['errors'] if details.present?
  end

  def last?
    self == snapshot_peers.last
  end

  def start(previous_snapshot = nil)
    handler.perform previous_snapshot
  end


  private

  def handler
    @handler ||= AdapterSnapshotHandler.new(self)
  end

  def snapshot_peers
    assignment_snapshot.adapter_snapshots
  end

  def set_up
    self.requested = (subtask == assignment_snapshot.requester)
    true
  end

end
