class Job < ApplicationRecord
  validates :title, presence: true
  validates :publisher, presence: true

  belongs_to :user
end