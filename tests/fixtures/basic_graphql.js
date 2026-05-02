const GET_USER_GQL = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
`;

const CREATE_USER_GQL = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
      email
      createdAt
    }
  }
`;

const USER_UPDATED_GQL = gql`
  subscription OnUserUpdated($userId: ID!) {
    userUpdated(userId: $userId) {
      id
      name
      status
    }
  }
`;

const USER_FIELDS_FRAGMENT = gql`
  fragment UserFields on User {
    id
    name
    email
    avatar {
      url
      thumbnail
    }
  }
`;

const SEARCH_USERS_GQL = gql`
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
`;

const GET_ENTITY_GQL = gql`
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
`;

const client = {
  graphql(strings, ...values) {
    return [strings, values];
  },
};

client.graphql`
  mutation DeleteUser($id: ID!) {
    deleteUser(id: $id) {
      success
    }
  }
`;

void GET_USER_GQL;
void CREATE_USER_GQL;
void USER_UPDATED_GQL;
void USER_FIELDS_FRAGMENT;
void SEARCH_USERS_GQL;
void GET_ENTITY_GQL;
