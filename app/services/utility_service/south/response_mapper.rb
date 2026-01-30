module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            id: note['Id'],
            title: note['TituloNota'],
            review: note['ReseniaNota'],
            content: note['Contenido'],
            created_at: note['FechaCreacion'],
            note_author_full_name: note['NombreCompletoAutor'],
            author_email: note['EmailAutor'],
            book_title: note['TituloLibro'],
            book_author_name: note['NombreAutorLibro'],
            book_genre: note['GeneroLibro']
          }
        end
      end
    end
  end
end
