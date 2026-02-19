# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  title      :string           not null
#  content    :string           not null
#  note_type  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user
  has_one :utility, through: :user

  enum note_type: { review: 0, critique: 1 }, _prefix: true

  validates :note_type, :content, :title,
            presence: true

  validate :review_word_count_limit

  def content_length
    return 'short' if word_count <= utility.lower_content_limit
    return 'medium' if word_count <= utility.upper_content_limit
    'long'
  end

  def word_count
    content.split.count
  end

  private

  def review_word_count_limit
    return if errors.present?
    return unless note_type_review?

    if word_count > utility.max_review_length
      errors.add(:content, I18n.t('active_record.models.note.errors.review_too_long', max_length: utility.max_review_length))
    end
  end
end
