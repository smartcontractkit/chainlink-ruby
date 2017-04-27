class Subtask::SnapshotsController < ExternalAdapterController

  before_filter :ensure_adapter
  before_filter :ensure_subtask

  def create
    snapshot = subtask.snapshot_requests.create(data: snapshot_params)

    success_response snapshot
  end


  private

  attr_reader :subtask

  def ensure_subtask
    @subtask = adapter.subtasks.find_by xid: subtask_xid

    if subtask.blank?
      response_404 'Not found.'
    end
  end

  def snapshot_params
    params.permit(:status, :value).merge({
      details: params[:details],
      fulfilled: true,
      summary: params[:summary],
      xid: params[:xid],
    })
  end

  def subtask_xid
    params[:subtask_id]
  end

end
