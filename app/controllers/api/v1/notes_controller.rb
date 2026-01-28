module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def note_type
        params.require(:type)
      end

      def notes_filtered
        Note.where(note_type: note_type, user_id: current_user.id)
            .order(created_at: params.require(:order))
            .page(params.require(:page))
            .per(params.require(:page_size))
      end

      def show_note
        Note.find_by!(id: params.require(:id), user_id: current_user.id)
      end
    end
  end
end