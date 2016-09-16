class ContractsController < ApplicationController

  before_filter :set_coordinator

  def create
    contract = ContractBuilder.perform(contract_params)

    if contract.persisted?
      render json: {
        acknowledged_at: Time.now.to_i.to_s,
        contract: contract,
        status: 'received',
      }
    else
      render json: {
        errors: contract.errors.full_messages,
        status: 'error',
      }
    end
  end


  private

  def contract_params
    params.require(:contract)
  end

end
