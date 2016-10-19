describe TermStatusPublisher, type: :model do

  describe "#perform" do
    let(:term) { factory_create :term }

    it "publishes the term's status into the NXT blockchain" do
      expect {
        TermStatusPublisher.perform(term.id)
      }.not_to raise_error
    end
  end

end
