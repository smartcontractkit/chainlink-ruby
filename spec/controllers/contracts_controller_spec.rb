describe ContractsController, type: :controller do
  describe "#create" do
    context "when authenticated" do
      before { coordinator_log_in }

      context "with valid params" do
        let(:contract_params) { JSON.parse(contract_json) }

        it "creates a new contract record" do
          expect {
            post :create, contract: contract_params
          }.to change {
            Contract.count
          }.by(+1)
        end

        it "responds with a received status" do
          post :create, contract: contract_params

          expect(response_json.status).to eq('received')
        end

        it "responds with an acknowledgement time" do
          post :create, contract: contract_params

          expect(response_json.acknowledged_at).to be_present
        end
      end

      context "with invalid params" do
        let(:contract_params) { {blah: 'D blah'} }

        it "creates a new contract record" do
          expect {
            post :create, contract: contract_params
          }.not_to change {
            Contract.count
          }
        end

        it "responds with a received status" do
          post :create, contract: contract_params

          expect(response_json.status).to eq('error')
        end

        it "responds without an acknowledgement time" do
          post :create, contract: contract_params

          expect(response_json.acknowledged_at).to be_blank
        end
      end
    end

    context "without authenticating" do
      let(:contract_params) { JSON.parse(contract_json) }

      it "creates a new contract record" do
        expect {
          post :create, contract: contract_params
        }.not_to change {
          Contract.count
        }
      end

      it "responds with a received status" do
        post :create, contract: contract_params

        expect(response).to be_unauthorized
      end
    end
  end
end
