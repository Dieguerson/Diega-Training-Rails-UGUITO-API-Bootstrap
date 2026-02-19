require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note, user: user) }

  let(:utility) { create(:utility) }
  let(:user) { create(:user, utility: utility) }

  %i[note_type title content].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_one(:utility).through(:user) }

  it { is_expected.to define_enum_for(:note_type).with_values([:review, :critique]).with_prefix(:note_type) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#content_length' do
    subject(:note) { build(:note, user: user, content: content) }

    context 'when content is short' do
      let(:content) { Faker::Lorem.sentence(word_count: utility.lower_content_limit - 1) }
      it 'should return short' do
        expect(note.content_length).to eq('short')
      end
    end

    context 'when content is medium' do
      let(:content) { Faker::Lorem.sentence(word_count: utility.lower_content_limit + 1) }
      it 'should return medium' do
        expect(note.content_length).to eq('medium')
      end
    end

    context 'when content is long' do
      let(:content) { Faker::Lorem.sentence(word_count: utility.upper_content_limit + 1) }
      it 'should return long' do
        expect(note.content_length).to eq('long')
      end
    end
  end

  describe 'Custom validations' do
    describe '#review_word_count_limit' do
      subject(:note) { build(:note, user: user, content: content, note_type: note_type) }

      context 'when note_type is review' do
        let(:note_type) { :review }
        let(:content) { Faker::Lorem.sentence(word_count: utility.max_review_length + 1) }
        it 'should validate word count' do
          expect{note.save!}.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when note_type is critique' do
        let(:note_type) { :critique }
        let(:content) { Faker::Lorem.sentence(word_count: utility.max_review_length + 1) }
        it 'should not validate word count' do
          expect(note).to be_valid
        end
      end
    end
  end
end
