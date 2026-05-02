def run():
  get_user_gql = """
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
    }
  }
  """

  create_user_gql = """
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
    }
  }
  """

  user_fields_fragment = """
  fragment UserFields on User {
    id
    name
    email
  }
  """

  search_users_gql = """
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
  """

  get_entity_gql = """
  query GetEntity($id: ID!) {
    entity(id: $id) {
      __typename
      ... on User {
        id
        name
      }
      ... on Organization {
        id
        displayName
      }
    }
  }
  """

  return (
    get_user_gql,
    create_user_gql,
    user_fields_fragment,
    search_users_gql,
    get_entity_gql,
  )
