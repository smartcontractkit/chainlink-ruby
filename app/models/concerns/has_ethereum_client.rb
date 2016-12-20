module HasEthereumClient


  private

  def ethereum
    @ethereum ||= Ethereum::Client.new
  end

end
