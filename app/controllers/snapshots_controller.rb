class SnapshotsController < ExternalAdapterController

  ASSIGNMENT_NAME = "%%!ASSIGNMENT_NAME!%%"

  skip_before_action :set_adapter, only: [:create, :show]
  before_filter :set_adapter_or_coordinator, only: [:create]
  before_filter :authenticate_coordinator, only: [:show]
  before_filter :ensure_snapshot, only: [:update]

  def create
    if adapter.present?
      snapshot = assignment.snapshots.create(snapshot_params)
    elsif coordinator.present?
      snapshot = assignment.check_status
    end

    success_response snapshot
  end

  def update
    if snapshot.update_attributes snapshot_params
      success_response snapshot
    else
      error_response snapshot.errors.full_messages
    end
  end

  def show
    snapshot = coordinator.snapshots.find_by xid: params[:id]

    if snapshot.present?
      success_response snapshot
    else
      error_response "No snapshot found."
    end
  end


  private

  attr_reader :snapshot

  def assignment
    @assignment ||= related.assignments.find_by xid: assignment_xid
  end

  def snapshot_params
    params.permit(:status, :value).merge({
      details: params[:details],
      fulfilled: true,
      summary: process_summary(params[:summary]),
      xid: xid,
    })
  end

  def ensure_snapshot
    unless @snapshot = assignment.snapshots.unfulfilled.find_by(xid: xid)
      error_response 'No eligible snapshots were found.'
    end
  end

  def process_summary(summary)
    summary.gsub(ASSIGNMENT_NAME, assignment.name)
  end

  def xid
    params[:id] || params[:xid]
  end

  def assignment_xid
    axid = params[:assignment_xid] ||
      params[:assignmentXID] ||
      params[:assignment_id]
    axid.gsub(/=.*/, '') if axid
  end

  def related
    @related ||= (adapter || coordinator)
  end

end
