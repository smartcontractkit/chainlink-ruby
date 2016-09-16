module HasBitcoinClient


  private

  def bitcoin
    @bitcoin ||= BitcoinClient.new
  end

end
