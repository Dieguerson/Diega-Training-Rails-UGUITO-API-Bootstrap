# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  utility_id :bigint(8)
#  user_id    :bigint(8)
#  title      :string           not null
#  content    :string           not null
#  note_type  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user
  belongs_to :utility

  before_validation :set_utility_from_user

  enum note_type: { review: 'review', critique: 'critique' }, _prefix: true, _scopes: true

  validate :review_word_count_limit

  def word_count
    content.split.count
  end

  def content_length
    return 'short' if word_count <= utility.lower_content_limit
    return 'medium' if word_count <= utility.upper_content_limit
    'long'
  end

  private

  def set_utility_from_user
    self.utility_id ||= user&.utility_id
  end

  def review_word_count_limit
    return unless note_type_review? && utility.present?

    if word_count > utility.max_review_length
      errors.add(:content, I18n.t('active_record.models.note.errors.review_too_long', max_length: utility.max_review_length))
    end
  end
end
