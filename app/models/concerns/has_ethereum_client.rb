module HasEthereumClient


  private

  def ethereum
    @ethereum ||= EthereumClient.new
  end

end
