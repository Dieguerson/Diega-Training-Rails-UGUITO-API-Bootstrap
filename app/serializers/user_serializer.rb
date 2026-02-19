class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :document_number, :last_name, :first_name
end
