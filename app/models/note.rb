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

  private

  def set_utility_from_user
    self.utility_id ||= user&.utility_id
  end
end
