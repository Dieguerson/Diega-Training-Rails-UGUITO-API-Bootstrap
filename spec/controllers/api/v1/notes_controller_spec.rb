require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_notes) { create_list(:note, 5, user: user) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: IndexNoteSerializer).to_json
      end

      context 'when fetching all the notes for user' do
        let(:notes_expected) { user.notes }

        before { get :index }

        it 'responds with the expected notes json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { user.notes.first(2) }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using filters' do
        let(:note_type) { :review }

        let(:notes_custom) { user.notes.where(note_type: note_type) }
        let(:notes_expected) { notes_custom }

        before { get :index, params: { type: note_type } }

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using invalid filters' do
        let(:note_type) { 'invalid' }
        let(:error_identifier) { 'invalid_note_type' }

        let(:expected) do
          {
            errors: [
              {
                status: 422,
                code: error_identifier,
                message: I18n.t("errors.messages.#{error_identifier}"),
                meta: nil
              }
            ]
          }.to_json
        end

        before { get :index, params: { type: note_type } }

        it 'responds with error message' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 422 status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the notes for user' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the note json' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching a invalid note' do
        before { get :show, params: { id: Faker::Number.number * 1000 } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching an note' do
        before { get :show, params: { id: Faker::Number.number * 1000 } }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'POST #create' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when creating a valid note' do
        let(:note_params) { { title: Faker::Lorem.sentence(word_count: 2), content: Faker::Lorem.sentence(word_count: 2), type: :review } }

        before { post :create, params: note_params }

        it 'responds with appropriate message' do
          expect(response_body['message']).to eq(I18n.t('active_record.models.note.created'))
        end

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when creating an invalid note' do
        context 'when note type is invalid' do
          let(:note_params) { { title: Faker::Lorem.sentence(word_count: 2), content: Faker::Lorem.sentence(word_count: 2), type: :invalid } }

          before { post :create, params: note_params }

          it 'responds with 422 status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when param is missing' do
          let(:note_params) { { title: Faker::Lorem.sentence(word_count: 2), content: Faker::Lorem.sentence(word_count: 2) } }

          before { post :create, params: note_params }

          it 'responds with 400 status' do
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when note_type is review but content is too long' do
          let(:note_params) { { title: Faker::Lorem.sentence(word_count: 2), content: Faker::Lorem.sentence(word_count: 200), type: :review } }

          before { post :create, params: note_params }

          it 'responds with 422 status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when creating an note' do
        before { post :create, params: { id: Faker::Number.number * 1000 } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
