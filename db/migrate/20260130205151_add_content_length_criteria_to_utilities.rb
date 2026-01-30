class AddContentLengthCriteriaToUtilities < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :lower_content_limit, :integer
    add_column :utilities, :upper_content_limit, :integer
    add_column :utilities, :max_review_length, :integer
  end
end
