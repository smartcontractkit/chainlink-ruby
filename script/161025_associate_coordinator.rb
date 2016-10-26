raise "only works with 1 Coordinator" if Coordinator.count != 1

coordinator = Coordinator.last

Assignment.update_all coordinator_id: coordinator.id
Contract.update_all coordinator_id: coordinator.id
