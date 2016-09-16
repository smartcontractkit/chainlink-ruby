KeyPair.where(private_key: nil).pluck(:id).each do |id|
  key = KeyPair.find id
  key.update_attributes private_key: key.old_private_key
end
