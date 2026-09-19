# frozen_string_literal: true

require_relative 'config/environment'

survey = Survey.first || abort("No seed data found. Run 'bundle exec ruby setup.rb' first.")

copy = survey.amoeba_dup
copy.save!

puts "Original: #{survey.title} - #{survey.sections.count} section(s), " \
     "#{survey.sections.sum { |section| section.questions.count }} question(s)"
puts "Copy:     #{copy.title} - #{copy.sections.count} section(s), " \
     "#{copy.sections.sum { |section| section.questions.count }} question(s)"

puts "\nSurvey title on the copy (amoeba prepended 'Copy of '):"
puts "  - #{copy.title}"

puts "\nSection titles on the copy (unchanged, amoeba only enabled recursion here):"
copy.sections.each { |section| puts "  - #{section.title}" }

puts "\nQuestion response counts on the copy (amoeba nullified them):"
copy.sections.each do |section|
  puts "  - #{section.title}"
  section.questions.each { |question| puts "    - #{question.text}: response_count=#{question.response_count.inspect}" }
end
