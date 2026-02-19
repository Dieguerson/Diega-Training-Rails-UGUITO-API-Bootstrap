require 'rails_helper'

RSpec.describe Utility, type: :model do
  NOTES_LIMITS = %i[lower_content_limit upper_content_limit max_review_length].freeze

  subject(:utility) do
    build(:utility)
  end

  %i[name type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  NOTES_LIMITS.each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  NOTES_LIMITS.each do |value|
    it { is_expected.to validate_numericality_of(value).only_integer.is_greater_than(0) }
  end

  it { is_expected.to have_many(:users).dependent(:destroy) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'custom validations' do
    describe '#upper_limit_greater_than_lower_limit' do
      context 'when upper_content_limit is greater than lower_content_limit' do
        it 'is valid' do
          utility.lower_content_limit = 50
          utility.upper_content_limit = 100
          expect(utility).to be_valid
        end
      end

      context 'when upper_content_limit is equal to lower_content_limit' do
        it 'is not valid' do
          utility.lower_content_limit = 50
          utility.upper_content_limit = 50
          expect(utility).not_to be_valid
          expect(utility.errors[:upper_content_limit]).to include('must be greater than lower content limit')
        end
      end

      context 'when upper_content_limit is less than lower_content_limit' do
        it 'is not valid' do
          utility.lower_content_limit = 100
          utility.upper_content_limit = 50
          expect(utility).not_to be_valid
          expect(utility.errors[:upper_content_limit]).to include('must be greater than lower content limit')
        end
      end
    end
  end
end
