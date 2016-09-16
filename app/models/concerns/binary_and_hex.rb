module BinaryAndHex

  def bin_to_hex(binary_string)
    binary_string.unpack('H*').first
  end

  def hex_to_bin(hex_string)
    [hex_string].pack('H*')
  end

end
