class ProjectSerializer < ActiveModel::Serializer
  class RepositorySerializer < ActiveModel::Serializer
    attributes :id, :full_name, :url
  end

  attributes :id, :created_at, :title, :public_header_background

  has_many :repositories, each_serializer: RepositorySerializer
end
