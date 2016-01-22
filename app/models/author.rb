class Author < ActiveRecord::Base
  has_many :tales

  validates :name, presence: true
  validates :name, uniqueness: true
end
