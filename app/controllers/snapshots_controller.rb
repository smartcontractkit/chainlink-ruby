class SnapshotsController < InputAdapterController

  ASSIGNMENT_NAME = "%%!ASSIGNMENT_NAME!%%"

  before_filter :ensure_snapshot, only: [:update]

  def create
    snapshot = assignment.snapshots.create(snapshot_params)
    success_response snapshot
  end

  def update
    if snapshot.update_attributes snapshot_params
      success_response snapshot
    else
      error_response snapshot.errors.full_messages
    end
  end


  private

  attr_reader :snapshot

  def assignment
    @assignment ||= adapter.assignments.find_by xid: params[:assignment_xid]
  end

  def snapshot_params
    params.permit(:status, :value).merge({
      details: params[:details],
      fulfilled: true,
      summary: process_summary(params[:summary]),
      xid: (params[:id] || params[:xid]),
    })
  end

  def ensure_snapshot
    unless @snapshot = assignment.snapshots.unfulfilled.find_by(xid: params[:xid])
      error_response 'No eligible snapshots were found.'
    end
  end

  def process_summary(summary)
    summary.gsub(ASSIGNMENT_NAME, assignment.name)
  end

end
