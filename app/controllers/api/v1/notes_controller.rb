module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: paginated_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      def create
        create_note
      end

      private

      def user_notes
        current_user.notes
      end

      def validated_note_type
        return nil if params[:type].blank?

        unless Note.note_types.keys.include?(params[:type])
          raise Exceptions::InvalidParameterError, 'invalid_note_type'
        end

        params[:type]
      end

      def filtered_notes
        return user_notes unless validated_note_type.present?

        user_notes.where(note_type: validated_note_type)
      end

      def order
        params[:order] || 'desc'
      end

      def paginated_notes
        filtered_notes
            .order(created_at: order)
            .page(params[:page])
            .per(params[:page_size])
      end

      def show_note
        user_notes.find_by!(id: params.require(:id))
      end

      def create_note_params
        params.require(%i[title type content])
        return {title: params[:title], note_type: validated_note_type, content: params[:content]}
      end

      def creation_success(note)
        render json: { 
          message: I18n.t('active_record.models.note.created'),
          note: note
        }, status: :created
      end

      def create_note
        note = Note.new(create_note_params.merge(user: current_user))
        if note.save
          creation_success(note)
        else
          render_error(:unprocessable_entity, message: note.errors.messages, status: :unprocessable_entity,)
        end
      end
    end
  end
end