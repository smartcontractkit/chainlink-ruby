FactoryGirl.define do

  factory :assignment_scheduled_update, class: Assignment::ScheduledUpdate do
    assignment
    run_at { 1.year.from_now }
  end

end
