# frozen_string_literal: true

require_relative 'config/environment'

load File.expand_path('db/schema.rb', __dir__)

survey = Survey.create!(title: 'Customer Satisfaction Q3')

SECTION_QUESTIONS = {
  'Demographics' => [
    'What is your age range?',
    'Which country do you live in?'
  ],
  'Product Feedback' => [
    'How satisfied are you with our product?',
    'How likely are you to recommend us to a friend?'
  ]
}.freeze

SECTION_QUESTIONS.each do |section_title, questions|
  section = survey.sections.create!(title: section_title)

  questions.each do |question_text|
    section.questions.create!(text: question_text, response_count: 42)
  end
end

puts "Seeded #{Survey.count} survey(s), #{Section.count} section(s), #{Question.count} question(s)."
