Assignment.pluck(:id).each do |id|
  assignment = Assignment.find(id)
  next if assignment.schedule.present?

  assignment.create_schedule!({
    hour: '0',
    minute: '0',
    day_of_month: '*',
    month_of_year: '*',
    day_of_week: '*',
  })
end
