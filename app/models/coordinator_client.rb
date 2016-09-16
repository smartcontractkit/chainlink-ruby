class CoordinatorClient

  include HttpClient
  base_uri ENV['COORDINATOR_CLIENT_URL']

  def self.snapshot(id)
    new.delay.snapshot(id)
  end

  def update_term(term_id)
    term = Term.find(term_id)

    check_acknowledged hashie_post('/contracts', {
      status_update: params_for(term, {
        signatures: term.outcome_signatures.flatten,
        status: term.status,
      })
    })
  end

  def oracle_instructions(oracle_id)
    oracle = EthereumOracle.find(oracle_id)
    contract = oracle.ethereum_contract
    template = contract.template

    check_acknowledged hashie_post('/oracles', {
      oracle: params_for(oracle.related_term, {
        address: contract.address,
        json_abi: template.json_abi,
        read_address: template.read_address,
        solidity_abi: template.solidity_abi,
      })
    })
  end

  def snapshot(snapshot_id)
    snapshot = AssignmentSnapshot.find snapshot_id
    attributes = AssignmentSnapshotSerializer.new(snapshot).attributes
    assignment = snapshot.assignment
    path = "/snapshots"

    hashie_post(path, params_for(assignment.term, attributes))
  end


  private

  def params_for(term, options = {})
    {
      contract: term.contract_xid,
      node_id: ENV['NODE_NAME'],
      term: term.name,
    }.merge(options)
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

  def coordinator
    Coordinator.last
  end

end
