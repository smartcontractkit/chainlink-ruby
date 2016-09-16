module HasCoordinatorClient


  private

  def coordinator
    @coordinator ||= CoordinatorClient.new
  end

end
