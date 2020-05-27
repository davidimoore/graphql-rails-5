class Types::UserConnectionType < GraphQL::Types::Relay::BaseConnection
  edge_type(UserEdgeType)

  field :total_count, Integer, null: false

  def total_count
    # - `object` is the Connection
    # - `object.items` is the original collection of Users
    object.items.size
  end
end