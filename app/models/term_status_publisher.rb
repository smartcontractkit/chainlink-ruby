class TermStatusPublisher

  def self.perform(id)
    term = Term.find(id)
    new(term).perform
  end

  def initialize(term)
    @term = term
    @contract = term.contract
  end

  def perform
    nil
  end


  private

  attr_reader :contract, :term

end
