class TermJanitor

  def self.clean_up
    Term.expired.pluck(:id).each do |term_id|
      delay.perform(term_id)
    end
  end

  def self.perform(term_id)
    new(Term.find term_id).perform
  end

  def initialize(term)
    @term = term
  end

  def perform
    term.update_status(default_final_status) if term.in_progress?
  end


  private

  attr_reader :term

  def default_final_status
    Term::COMPLETED
  end

end
