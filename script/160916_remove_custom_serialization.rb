EthereumOracle.pluck(:id).each do |id|
  oracle = EthereumOracle.find(id)
  fields = oracle.field_list.blank? ? [] : oracle.field_list.split(FIELD_DELIMITER)
  oracle.update_attributes fields: fields
end

CustomExpectation.pluck(:id).each do |id|
  oracle = CustomExpectation.find(id)
  fields = oracle.field_list.blank? ? [] : oracle.field_list.split(FIELD_DELIMITER)
  oracle.update_attributes fields: fields
end
