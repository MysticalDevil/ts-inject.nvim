object GraphQLMain {
  val GET_USER_GQL = """
    query GetUser($id: ID!) {
      user(id: $id) {
        id
        name
        email
      }
    }
  """

  val createUserGql = """
    mutation CreateUser($input: CreateUserInput!) {
      createUser(input: $input) {
        id
        name
        email
      }
    }
  """

  val userUpdatedGql = """
    subscription OnUserUpdated($userId: ID!) {
      userUpdated(userId: $userId) {
        id
        name
        status
      }
    }
  """

  val userFieldsGql = """
    fragment UserFields on User {
      id
      name
      email
    }
  """

  val searchUsersGql = """
    query SearchUsers($query: String!, $includeInactive: Boolean!) {
      activeUsers: users(query: $query, status: ACTIVE) {
        ...UserFields
      }
      inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
        ...UserFields
      }
    }
  """

  val getEntityGql = """
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
}
