class Api::V1::Record < ApplicationRecord
    validates :title, presence: true
    validates :img, presence: true
end
