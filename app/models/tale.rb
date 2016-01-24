class Tale < ActiveRecord::Base
  belongs_to :category
  belongs_to :author

  has_many :chapters
  validates :name, uniqueness: {scope: [:author_id, :category_id, :link]}
end
