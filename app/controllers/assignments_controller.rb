class AssignmentsController < InputAdapterController

  skip_before_filter :set_adapter, only: [:create]
  before_filter :set_coordinator, only: [:create]
  before_filter :check_adapter_permissions, only: [:update]

  def create
    assignment = coordinator.create_assignment params[:assignment]

    if assignment.persisted?
      success_response assignment
    else
      error_response assignment.errors.full_messages
    end
  end

  def update
    if assignment.update_status params[:status]
      success_response assignment
    else
      error_response assignment.term.errors.full_messages
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

end
