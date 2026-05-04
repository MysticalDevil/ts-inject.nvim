fn main() {
    let get_user_gql = r#"
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
"#;

    let create_user_graphql = r#"
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
      email
    }
  }
"#;

    let user_updated_gql = r#"
  subscription OnUserUpdated($userId: ID!) {
    userUpdated(userId: $userId) {
      id
      name
      status
    }
  }
"#;

    let user_fields_fragment = r#"
  fragment UserFields on User {
    id
    name
    email
  }
"#;

    let search_users_gql = r#"
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
"#;

    let get_entity_gql = r#"
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
"#;

    let some_query = r#"
  query GetUsers {
    users {
      id
    }
  }
"#;

    let _delete_macro = graphql!(
        r#"
  mutation DeleteUser($id: ID!) {
    deleteUser(id: $id) {
      success
    }
  }
"#
    );

    let _simple_macro = gql!(r#"query SimpleQuery { simple { id } }"#);

    let _ = (
        get_user_gql,
        create_user_graphql,
        user_updated_gql,
        user_fields_fragment,
        search_users_gql,
        get_entity_gql,
        some_query,
        _delete_macro,
        _simple_macro,
    );
}
