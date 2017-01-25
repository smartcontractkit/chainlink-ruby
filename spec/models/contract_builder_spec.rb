describe ContractBuilder, type: :model do

  describe "#perform" do
    let(:coordinator) { factory_create :coordinator }
    subject(:contract) { ContractBuilder.perform(json, coordinator) }

    context "when valid payment term params are passed in" do
      let(:outcomes) { true }
      let(:json) { JSON.parse(contract_json outcomes: outcomes) }

      it "returns a saved contract without errors" do
        expect(contract).to be_persisted
      end

      it "returns a contract without errors" do
        expect(contract.errors).to be_blank
      end

      it "creates a new contract" do
        expect {
          subject
        }.to change {
          Contract.count
        }.by(+1)
      end

      it "creates new terms" do
        expect {
          subject
        }.to change {
          Term.count
        }.by(+1)
      end

      it "associates the new contract with the coordinator" do
        expect {
          subject
        }.to change {
          coordinator.reload.contracts.count
        }.by(+1)
      end

      it "associates the new assignment with the coordinator" do
        expect {
          subject
        }.to change {
          coordinator.reload.assignments.count
        }.by(+1)
      end

      it "creates new a new assignment" do
        expect {
          subject
        }.to change {
          EthereumOracle.count
        }.by(+1)
      end

      it "creates new outcomes if there are any" do
        expect {
          subject
        }.to change {
          EscrowOutcome.count
        }.by(+2)
      end

      context "when there are no outcomes" do
        let(:outcomes) { false }

        it "still creates everything else" do
          expect {
            subject
          }.to change {
            Contract.count
          }.by(+1)
        end
      end

      context "when an expectation type is passed in for an input adapter" do
        let(:adapter) { factory_create :external_adapter }
        let(:json) { JSON.parse(contract_json term: term_json(type: adapter.type)) }

        it "creates a contract" do
          expect {
            subject
          }.to change {
            Contract.count
          }.by(+1)
        end

        it "creates new a new assignment for the adapter of that type" do
          expect {
            subject
          }.to change {
            adapter.reload.assignments.count
          }.by(+1)
        end
      end

      context "when Custom API params are passed in" do
        let(:json) { JSON.parse(contract_json term: custom_term_json) }

        it "still creates a contract" do
          expect {
            subject
          }.to change {
            Contract.count
          }.by(+1)
        end

        it "creates a new custom bitcoin expectation" do
          expect {
            subject
          }.to change {
            CustomExpectation.count
          }.by(+1)
        end

        it "creates a new assignment schedule" do
          expect {
            subject
          }.to change {
            AssignmentSchedule.count
          }.by(+1)

          assignment = AssignmentSchedule.last
          expect(assignment.minute).to eq('0')
          expect(assignment.hour).to eq('*')
        end
      end

      context "when Oracle API params are passed in" do
        let(:json) { JSON.parse(contract_json term: oracle_term_json) }

        it "still creates a contract" do
          expect {
            subject
          }.to change {
            Contract.count
          }.by(+1)
        end

        it "creates new a new SEO expectation" do
          expect {
            subject
          }.to change {
            EthereumOracle.count
          }.by(+1)
        end

        it "creates a new assignment schedule" do
          expect {
            subject
          }.to change {
            AssignmentSchedule.count
          }.by(+1)

          assignment = AssignmentSchedule.last
          expect(assignment.minute).to eq('0')
          expect(assignment.hour).to eq('0')
        end

        context "when a schedule is set" do
          let(:schedule) { {minute: '1', hour: '2', dayOfMonth: '3', monthOfYear: '4', dayOfWeek: '5'} }
          let(:json) { JSON.parse(contract_json term: oracle_term_json(schedule: schedule)) }

          it "creates a new assignment schedule" do
            expect {
              subject
            }.to change {
              AssignmentSchedule.count
            }.by(+1)

            assignment = AssignmentSchedule.last
            expect(assignment.minute).to eq('1')
            expect(assignment.hour).to eq('2')
            expect(assignment.day_of_month).to eq('3')
            expect(assignment.month_of_year).to eq('4')
            expect(assignment.day_of_week).to eq('5')
          end
        end
      end
    end

    context "when invalid params are passed in" do
      let(:json) do
        JSON.parse(contract_json, outcomes: true).tap do |json|
          json['contract'].delete('id')
        end
      end

      it "returns an unpersisted" do
        expect(contract).not_to be_persisted
      end

      it "returns a contract with errors" do
        expect(contract.errors).to be_present
      end

      it "does not create a new contract" do
        expect {
          subject
        }.not_to change {
          Contract.count
        }
      end

      it "does not create new terms" do
        expect {
          subject
        }.not_to change {
          Term.count
        }
      end

      it "returns errors with the JSON schema" do
        errors = contract.errors.full_messages

        expect(errors).to include "The property '#/contract' did not contain a required property of 'id'"
      end

      it "catches errors that are raised and attaches them to the contract" do
        error_text = "Foo Error Baz"

        expect(EthereumOracle).to receive(:new)
          .and_raise(error_text)

        expect(contract).not_to be_persisted
        expect(contract.errors.full_messages).to include error_text
      end
    end

    context "when there are invalid params in the expectation" do
      let(:json) do
        JSON.parse(contract_json term: custom_term_json).tap do |json|
          json['contract']['terms'][0]['expected']['endpoint'] = 'barf'
        end
      end

      it "returns an unpersisted" do
        expect(contract).not_to be_persisted
      end

      it "returns a contract with errors" do
        expect(contract.errors).to be_present
      end

      it "does not create a new contract" do
        expect {
          subject
        }.not_to change {
          Contract.count
        }
      end

      it "does not create new terms" do
        expect {
          subject
        }.not_to change {
          Term.count
        }
      end

      it "returns errors with the JSON schema" do
        expect(contract.errors.full_messages).to include "Term Error: Assignment Error: Adapter#0 Error: Endpoint is invalid"
      end
    end
  end

end
