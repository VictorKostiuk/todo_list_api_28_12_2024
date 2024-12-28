class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  belongs_to :list
end
