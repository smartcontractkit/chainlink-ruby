describe Coordinator, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:key).when(SecureRandom.hex) }
    it { is_expected.to have_valid(:secret).when(SecureRandom.hex) }

    it { is_expected.to have_valid(:url).when(nil, '', "https://www.example.com:1234/api") }
    it { is_expected.not_to have_valid(:url).when('www.example.com:1234/api', 'blah') }
  end

  describe "on create" do
    let(:coordinator) { Coordinator.new }

    it "generates all the necessary credentials" do
      expect {
        coordinator.save
      }.to change {
        coordinator.key
      }.from(nil).and change {
        coordinator.secret
      }.from(nil)
    end
  end

  describe "#update_term" do
    let(:coordinator) { factory_create :coordinator, url: url }
    let(:client) { instance_double CoordinatorClient }
    let(:term_id) { SecureRandom.hex }

    before do
      allow(CoordinatorClient).to receive(:new)
        .and_return(client)
    end

    context "when the coordinator has a URL" do
      let(:url) { "http://localhost:3000/api" }

      it "queues a job for the coordinator client" do
        expect(client).to receive_message_chain(:delay, :update_term)
          .with(term_id)

        coordinator.update_term(term_id)
      end
    end

    context "when the coordinator does not have a URL" do
      let(:url) { nil }

      it "does not queue a job for the coordinator client" do
        expect(client).not_to receive(:delay)

        coordinator.update_term(term_id)
      end
    end
  end

  describe "#snapshot" do
    let(:coordinator) { factory_create :coordinator, url: url }
    let(:client) { instance_double CoordinatorClient }
    let(:snapshot_id) { SecureRandom.hex }

    before do
      allow(CoordinatorClient).to receive(:new)
        .and_return(client)
    end

    context "when the coordinator has a URL" do
      let(:url) { "http://localhost:3000/api" }

      it "queues a job for the coordinator client" do
        expect(client).to receive_message_chain(:delay, :snapshot)
          .with(snapshot_id)

        coordinator.snapshot(snapshot_id)
      end
    end

    context "when the coordinator does not have a URL" do
      let(:url) { nil }

      it "does not queue a job for the coordinator client" do
        expect(client).not_to receive(:delay)

        coordinator.snapshot(snapshot_id)
      end
    end
  end

  describe "#assignment_initialized" do
    let(:coordinator) { factory_create :coordinator, url: url }
    let(:client) { instance_double CoordinatorClient }
    let(:assignment_id) { SecureRandom.hex }

    before do
      allow(CoordinatorClient).to receive(:new)
        .and_return(client)
    end

    context "when the coordinator has a URL" do
      let(:url) { "http://localhost:3000/api" }

      it "queues a job for the coordinator client" do
        expect(client).to receive_message_chain(:delay, :assignment_initialized)
          .with(assignment_id)

        coordinator.assignment_initialized(assignment_id)
      end
    end

    context "when the coordinator does not have a URL" do
      let(:url) { nil }

      it "does not queue a job for the coordinator client" do
        expect(client).not_to receive(:delay)

        coordinator.assignment_initialized(assignment_id)
      end
    end
  end
end
