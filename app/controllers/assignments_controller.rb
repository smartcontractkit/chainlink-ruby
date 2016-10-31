class AssignmentsController < InputAdapterController

  skip_before_filter :set_adapter, only: [:create]
  before_filter :set_coordinator, only: [:create]
  before_filter :check_adapter_permissions, only: [:update]

  def create
    req = AssignmentRequest.new assignment_request_params

    if req.save
      success_response req
    else
      error_response req.errors.full_messages
    end
  end

  def update
    if assignment.update_status params[:status]
      success_response assignment
    else
      error_response assignment.errors.full_messages
    end
  end


  private

  def assignment
    @assignmnet ||= adapter.assignments.find_by({
      xid: (params[:xid] || params[:id])
    })
  end

  def check_adapter_permissions
    response_404 'Assignment not found' if assignment.nil?
  end

  def assignment_request_params
    {
      body_json: params.except(:action, :controller).to_json,
      body_hash: params[:assignmentHash],
      coordinator: coordinator,
    }
  end

end
