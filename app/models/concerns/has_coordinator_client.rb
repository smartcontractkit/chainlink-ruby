module HasCoordinatorClient


  private

  def coordinator_client
    @coordinator_client ||= CoordinatorClient.new coordinator
  end

end
