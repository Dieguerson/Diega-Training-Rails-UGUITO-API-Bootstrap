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

      private

      def user_notes
        current_user.notes
      end

      def note_type
        return nil if params[:type].blank?

        unless Note.note_types.keys.include?(params[:type])
          raise Exceptions::InvalidParameterError, 'invalid_note_type'
        end

        params[:type]
      end

      def filtered_notes
        return user_notes unless note_type.present?

        user_notes.where(note_type: note_type)
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
    end
  end
end