module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['id'],
            title: book['titulo'],
            author: book['autor'],
            genre: book['genero'],
            image_url: book['imagen_url'],
            publisher: book['editorial'],
            year: book['año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            id: note['id'],
            title: note['titulo'],
            note_type: note['tipo'],
            content: note['contenido'],
            created_at: note['fecha_creacion'],
            author: map_author(note['autor']),
            book: map_book(note['libro'])
          }
        end
      end

      def map_author(author)
        return nil unless author.present?

        {
          contact_info: {
            email: author['datos_de_contacto']['email'],
            phone: author['datos_de_contacto']['telefono']
          },
          personal_info: {
            document_number: author['datos_personales']['nro_documento'],
            name: author['datos_personales']['nombre'],
            last_name: author['datos_personales']['apellido']
          }
        }
      end

      def map_book(book)
        return nil unless book.present?

        {
          id: book['id'],
          title: book['titulo'],
          created_at: book['fecha_creacion'],
          author: book['autor'],
          genre: book['genero'],
          image_url: book['imagen_url'],
          publisher: book['editorial'],
          year: book['año']
        }
      end
    end
  end
end
