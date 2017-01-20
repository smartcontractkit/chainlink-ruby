class CoordinatorClient

  include HttpClient

  def initialize(coordinator)
    @coordinator = coordinator
  end

  def update_term(term_id)
    return unless url?
    term = Term.find(term_id)

    check_acknowledged coordinator_post('/contracts', {
      statusUpdate: params_for(term, {
        signatures: term.outcome_signatures.flatten,
        status: term.status,
      })
    })
  end

  def oracle_instructions(contract_id)
    return unless url?
    contract = EthereumContract.find(contract_id)
    oracle = contract.owner
    template = contract.template

    check_acknowledged coordinator_post('/oracles', {
      oracle: params_for(oracle.related_term, {
        address: contract.address,
        jsonABI: template.json_abi,
        readAddress: template.read_address,
        solidityABI: template.solidity_abi,
      })
    })
  end

  def snapshot(snapshot_id)
    return unless url?
    snapshot = AssignmentSnapshot.find snapshot_id
    attributes = AssignmentSnapshotSerializer.new(snapshot).attributes
    term = snapshot.assignment.term
    path = "/snapshots"

    coordinator_post path, params_for(term, attributes)
  end

  def assignment_initialized(assignment_id)
    return unless url?
    assignment = Assignment.find(assignment_id)
    term = assignment.term

    path = "/assignments/#{assignment.xid}"
    check_acknowledged coordinator_post(path, params_for(term, {
      initializationDetails: assignment.initialization_details,
      xid: assignment.xid,
    }))
  end


  private

  attr_reader :coordinator

  def params_for(term, options = {})
    {
      contract: term.try(:contract_xid),
      nodeID: ENV['NODE_NAME'],
      term: term.try(:name),
    }.compact.merge(options)
  end

  def check_acknowledged(response)
    if response.acknowledged_at.blank?
      raise "Not acknowledged, try again. Errors: #{response.errors}"
    else
      response
    end
  end

  def http_client_auth_params
    {
      password: coordinator.secret,
      username: coordinator.key,
    }
  end

  def coordinator_post(path, params)
    url = coordinator.url + path
    hashie_post(url, params)
  end

  def url?
    coordinator.url.present?
  end

end
