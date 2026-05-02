using System;

class GraphQLProgram {
    static void Main() {
        const string GET_USER_GQL = @"
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    email
  }
}
";

        var createUserGql = @"
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    name
    email
  }
}
";

        var userUpdatedGql = @"
subscription OnUserUpdated($userId: ID!) {
  userUpdated(userId: $userId) {
    id
    name
    status
  }
}
";

        var userFieldsGql = @"
fragment UserFields on User {
  id
  name
  email
}
";

        var searchUsersGql = @"
query SearchUsers($query: String!, $includeInactive: Boolean!) {
  activeUsers: users(query: $query, status: ACTIVE) {
    ...UserFields
  }
  inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
    ...UserFields
  }
}
";

        var getEntityGql = @"
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
";

        Console.WriteLine(GET_USER_GQL);
        Console.WriteLine(createUserGql);
        Console.WriteLine(userUpdatedGql);
        Console.WriteLine(userFieldsGql);
        Console.WriteLine(searchUsersGql);
        Console.WriteLine(getEntityGql);
    }
}
