ActiveAdmin.register Book do
  filter :title
  filter :author
  filter :genre
  filter :publisher
  filter :year
  filter :utility
  filter :user
  filter :created_at
  filter :updated_at

  permit_params = %i[
    utility_id user_id genre author image title publisher year
  ]

  member_action :copy, method: :get do
    @book = resource.dup
    render :new, layout: false
  end

  action_item :copy, only: :show do
    link_to(I18n.t('active_admin.clone_model', model: 'Book'),
            copy_admin_book_path(id: resource.id))
  end

  controller do
    define_method :permitted_params do
      params.permit(active_admin_namespace.permitted_params, book: permit_params)
    end

    def scoped_collection
      super.includes(:utility, :user)
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :genre
    column :publisher
    column :year
    column :utility
    column :user
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :author
      row :genre
      row :publisher
      row :year
      row :image
      row :utility
      row :user
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Book Details' do
      f.semantic_errors(*f.object.errors.keys)
      f.input :utility, as: :select, collection: Utility.all
      f.input :user, as: :select, collection: User.all
      f.input :title
      f.input :author
      f.input :genre
      f.input :publisher
      f.input :year
      f.input :image, as: :url
      f.actions
    end
  end
end
