describe CoordinatorClient, type: :model do
  let(:url) { "http://localhost:3000/api" }
  let(:coordinator) { factory_create :coordinator, url: url }
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

    context "when the coordinator has a URL" do
      before do
        allow(Term).to receive(:find).and_return(term)

        expect(CoordinatorClient).to receive(:post)
          .with("#{coordinator.url}/contracts", {
            basic_auth: instance_of(Hash),
            body: {
              statusUpdate: {
                contract: xid,
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

    context "when the coordinator URL does NOT have a URL" do
      let(:url) { nil }

      it "does NOT post" do
        expect(CoordinatorClient).not_to receive(:post)

        client.update_term term.id
      end
    end
  end

  describe "#snapshot" do
    let(:snapshot) { factory_create :assignment_snapshot, assignment: assignment }
    let(:assignment) { factory_create :assignment }

    context "when the coordinator has a URL" do
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

    context "when the coordinator URL does NOT have a URL" do
      let(:url) { nil }

      it "does NOT post" do
        expect(CoordinatorClient).not_to receive(:post)

        client.snapshot snapshot.id
      end
    end
  end

  describe "#assignment_initialized" do
    let!(:term) { factory_create :term, expectation: assignment }
    let(:assignment) { factory_create :assignment }
    let(:response) { http_response body: {acknowledged_at: 1}.to_json }

    before do
      expect(CoordinatorClient).to receive(:patch)
        .with("#{coordinator.url}/assignments/#{assignment.xid}", {
          basic_auth: instance_of(Hash),
          body: {
            contract: term.contract.xid,
            subtasks: assignment.initialization_details,
            term: term.name,
            xid: assignment.xid,
          },
          headers: {}
        }).and_return(response)
    end

    context "when the response comes back acknowledged" do
      let(:response) { http_response body: {acknowledged_at: 1}.to_json }

      it "does not raise an error" do
        expect {
          client.assignment_initialized assignment.id
        }.not_to raise_error
      end
    end

    context "when the response comes back unacknowledged" do
      let(:response) { http_response body: {}.to_json }

      it "raise an error" do
        expect {
          client.assignment_initialized assignment.id
        }.to raise_error "Not acknowledged, try again. Errors: "
      end
    end
  end
end
