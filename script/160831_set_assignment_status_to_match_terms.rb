Assignment.pluck(:id).each do |id|
  assignment = Assignment.find(id)
  term = assignment.term

  assignment.update_attributes!({
    end_at: (assignment.end_at || term.end_at),
    start_at: (assignment.start_at || assignment.created_at),
    status: (assignment.status || term.status),
  })
end
