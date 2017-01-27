class HealthCheck

  include HasEthereumClient

  attr_reader :errors


  def self.perform
    Notification.health_check.deliver_now
  end

  def self.eth_external_block_height
    if url = ENV['ETHEREUM_EXTERNAL_HEIGHT_URL']
      json = JSON.parse(HTTParty.get(url).body)
      Ethereum::Client.new.hex_to_int(json['result'])
    end
  end


  def initialize
    @errors = {}
  end

  def eth_unconfirmed_tx_count
    @eth_unconfirmed_tx_count ||= EthereumTransaction.unconfirmed.count
  end

  def eth_external_block_height
    begin
      @eth_external_block_height ||= self.class.eth_external_block_height
    rescue Exception => error
      add_error "external block height", error
    end
  end

  def eth_internal_block_height
    begin
      @eht_internal_block_height ||= ethereum.current_block_height
    rescue Exception => error
      add_error "internal block height", error
    end
  end

  def delayed_job_count
    @delayed_job_count ||= Delayed::Job.count
  end

  def eth_block_height_difference
    if eth_internal_block_height.present? && eth_external_block_height.present?
      (eth_internal_block_height - eth_external_block_height).abs
    elsif eth_internal_block_height.blank?
      add_error "ethereum client", "NOT CONNECTED"
    end
  end

  def status
    return 'Questionable' if eth_unconfirmed_tx_count > 0
    height_diff = eth_block_height_difference
    return 'Questionable' if height_diff.present? && height_diff > 0
    return 'ERROR' if errors.present?
    "OK"
  end


  private

  def add_error(calculation, error)
    self.errors[calculation] = error.to_s
    nil
  end

end
