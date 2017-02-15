FactoryGirl.define do

  factory :assignment_schedule do
    assignment
    minute { '0' }
    hour { '0' }
    day_of_month { '*' }
    month_of_year { '*' }
    day_of_week { '*' }
    end_at { 1.year.from_now }
  end

end
