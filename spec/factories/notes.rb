FactoryBot.define do
  factory :note do
    user
    utility
    title { Faker::Lorem.sentence(word_count: 3) }
    note_type { %w[review critique].sample }
    
    content do
      min_words = 45
      max_words = 150

      if note_type == 'review' && utility.present?
        max_words = [max_words, utility.max_review_length].min
      end
      
      # Ensure min <= max
      max_words = min_words if max_words < min_words
      
      word_count = rand(min_words..max_words)
      Faker::Lorem.sentence(word_count: word_count)
    end
  end
end
