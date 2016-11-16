describe CoordinatorClient, type: :model do
  let(:coordinator) { factory_create :coordinator }
  let(:client) { CoordinatorClient.new coordinator }

  describe "#update_term" do
    let(:xid) { SecureRandom.hex }
    let(:outcome_signatures) { [[SecureRandom.hex]] }
    let(:term_status) { "whatevz" }
    let(:term_name) { "whatev2" }
    let(:term) do
      instance_double(Term, {
        id: 42,
        contract_xid: xid,
        outcome_signatures: outcome_signatures,
        status: term_status,
        name: term_name
      })
    end

    before do
      allow(Term).to receive(:find).and_return(term)

      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator.url}/contracts", {
          basic_auth: instance_of(Hash),
          body: {
            statusUpdate: {
              contract: xid,
              nodeID: ENV['NODE_NAME'],
              signatures: outcome_signatures.flatten,
              status: term_status,
              term: term_name
            }
          },
          headers: {}
      }).and_return(response)
    end

    context "when the response comes back acknowledged" do
      let(:response) { http_response body: {acknowledged_at: 1}.to_json }

      it "does not raise an error" do
        expect {
          client.update_term term.id
        }.not_to raise_error
      end
    end

    context "when the response comes back unacknowledged" do
      let(:response) { http_response body: {}.to_json }

      it "raise an error" do
        expect {
          client.update_term term.id
        }.to raise_error "Not acknowledged, try again. Errors: "
      end
    end
  end

  describe "#oracle_instructions" do
    let(:oracle) { factory_create :ethereum_oracle }
    let(:ethereum_contract) { oracle.ethereum_contract }
    let(:template) { ethereum_contract.template }
    let(:term) { factory_create :term, expectation: oracle }
    let(:contract) { term.contract }
    let(:response) { http_response body: {acknowledged_at: 1}.to_json }

    before do
      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator.url}/oracles", {
          basic_auth: instance_of(Hash),
          body: {
            oracle: {
              address: ethereum_contract.address,
              contract: contract.xid,
              jsonABI: template.json_abi,
              nodeID: ENV['NODE_NAME'],
              readAddress: template.read_address,
              solidityABI: template.solidity_abi,
              term: term.name,
            }
          },
          headers: {}
        }).and_return(response)
    end

    context "when the response comes back acknowledged" do
      let(:response) { http_response body: {acknowledged_at: 1}.to_json }

      it "does not raise an error" do
        expect {
          client.oracle_instructions oracle.id
        }.not_to raise_error
      end
    end

    context "when the response comes back unacknowledged" do
      let(:response) { http_response body: {}.to_json }

      it "raise an error" do
        expect {
          client.oracle_instructions oracle.id
        }.to raise_error "Not acknowledged, try again. Errors: "
      end
    end
  end

  describe "#snapshot" do
    let(:snapshot) { factory_create :assignment_snapshot, assignment: assignment }
    let(:assignment) { factory_create :assignment }

    context "when the assignment has a term" do
      let(:term) { factory_create :term }
      let(:contract) { term.contract }

      before do
        assignment.update_attributes term: term

        expect(CoordinatorClient).to receive(:post)
          .with("#{coordinator.url}/snapshots", {
            basic_auth: instance_of(Hash),
            body: {
              contract: contract.xid,
              assignmentXID: assignment.xid,
              description: snapshot.description,
              descriptionURL: snapshot.description_url,
              details: snapshot.details,
              nodeID: ENV['NODE_NAME'],
              status: snapshot.status,
              summary: snapshot.summary,
              term: term.name,
              value: snapshot.value,
              xid: snapshot.xid,
            },
            headers: {}
          }).and_return(response)
      end

      context "when the response comes back acknowledged" do
        let(:response) { http_response }

        it "does not raise an error" do
          expect {
            client.snapshot snapshot.id
          }.not_to raise_error
        end
      end

      context "when the response comes back unacknowledged" do
        let(:response) { http_response success?: false }

        it "raise an error" do
          expect {
            client.snapshot snapshot.id
          }.to raise_error "Not acknowledged, try again. Errors: {}"
        end
      end
    end

    context "when the assignment has a term" do
      let(:term) { nil }

      before do
        expect(CoordinatorClient).to receive(:post)
          .with("#{coordinator.url}/snapshots", {
            basic_auth: instance_of(Hash),
            body: {
              assignmentXID: assignment.xid,
              description: snapshot.description,
              descriptionURL: snapshot.description_url,
              details: snapshot.details,
              nodeID: ENV['NODE_NAME'],
              status: snapshot.status,
              summary: snapshot.summary,
              value: snapshot.value,
              xid: snapshot.xid,
            },
            headers: {}
          }).and_return(response)
      end

      context "when the response comes back acknowledged" do
        let(:response) { http_response }

        it "does not raise an error" do
          expect {
            client.snapshot snapshot.id
          }.not_to raise_error
        end
      end

      context "when the response comes back unacknowledged" do
        let(:response) { http_response success?: false }

        it "raise an error" do
          expect {
            client.snapshot snapshot.id
          }.to raise_error "Not acknowledged, try again. Errors: {}"
        end
      end
    end
  end
end
