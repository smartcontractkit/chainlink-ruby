describe Ethereum::Event do

  describe "validations" do
    it { is_expected.to have_valid(:address).when(ethereum_address) }
    it { is_expected.not_to have_valid(:address).when(nil) }

    it { is_expected.to have_valid(:block_hash).when("0x#{ SecureRandom.hex 32 }") }
    it { is_expected.not_to have_valid(:block_hash).when(nil, '', "0x", "0x#{ SecureRandom.hex 33 }") }

    it { is_expected.to have_valid(:block_number).when(0, 1) }
    it { is_expected.not_to have_valid(:block_number).when(-1, nil) }

    it { is_expected.to have_valid(:data).when(nil, '', "0x", "0x#{SecureRandom.hex 256}") }

    it { is_expected.to have_valid(:log_index).when(0, 1) }
    it { is_expected.not_to have_valid(:log_index).when(-1, nil) }

    it { is_expected.to have_valid(:log_subscription).when(factory_create :ethereum_log_subscription) }
    it { is_expected.not_to have_valid(:log_subscription).when(nil) }

    it { is_expected.to have_valid(:transaction_hash).when("0x#{ SecureRandom.hex 32 }") }
    it { is_expected.not_to have_valid(:transaction_hash).when(nil, '', "0x", "0x#{ SecureRandom.hex 33 }") }

    it { is_expected.to have_valid(:transaction_index).when(0, 1) }
    it { is_expected.not_to have_valid(:transaction_index).when(-1, nil) }

    context "when the block number and log number are the same" do
      let(:old) { factory_create :ethereum_event }
      subject { Ethereum::Event.new block_number: old.block_number }

      it { is_expected.not_to have_valid(:log_index).when(old.log_index) }
    end
  end

  describe "on create" do
    let(:event) { factory_build :ethereum_event }

    it "notifies the event of its creation" do
      expect_any_instance_of(Ethereum::LogSubscription).to receive(:log) do |subscription, event|
        expect(subscription).to eq(event.log_subscription)
        expect(event).to eq(event)
      end

      run_generated_jobs { event.save }
    end
  end

end
