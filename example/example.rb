# frozen_string_literal: true

require_relative 'config/environment'

original = Survey.first || abort("No seed data found. Run 'bundle exec ruby setup.rb' first.")

copy = original.amoeba_dup
copy.save!

def display(survey)
  puts "Title: #{survey.title}"
  survey.sections.each_with_index do |section, i|
    puts "  Section #{i + 1} title: #{section.title}"
    section.questions.each_with_index do |question, j|
      puts "    Question #{j + 1}: #{question.text}"
      puts "      #{question.response_count.inspect} responses"
    end
  end
end

puts '=== Original survey ==='
display(original)
puts '======================='
puts

puts '=== Cloned survey  ==='
display(copy)
puts '======================='
