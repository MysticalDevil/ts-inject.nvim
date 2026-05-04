class GraphQLMain {
  void run() {
    String GET_USER_GQL =
        """
        query GetUser($id: ID!) {
          user(id: $id) {
            id
            name
            email
          }
        }
        """;

    String createUserGql =
        """
        mutation CreateUser($input: CreateUserInput!) {
          createUser(input: $input) {
            id
            name
            email
          }
        }
        """;

    String userUpdatedGql =
        """
        subscription OnUserUpdated($userId: ID!) {
          userUpdated(userId: $userId) {
            id
            name
            status
          }
        }
        """;

    String userFieldsGql =
        """
        fragment UserFields on User {
          id
          name
          email
        }
        """;

    String searchUsersGql =
        """
        query SearchUsers($query: String!, $includeInactive: Boolean!) {
          activeUsers: users(query: $query, status: ACTIVE) {
            ...UserFields
          }
          inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
            ...UserFields
          }
        }
        """;

    String getEntityGql =
        """
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
        """;

    System.out.println(GET_USER_GQL);
    System.out.println(createUserGql);
    System.out.println(userUpdatedGql);
    System.out.println(userFieldsGql);
    System.out.println(searchUsersGql);
    System.out.println(getEntityGql);
  }
}
