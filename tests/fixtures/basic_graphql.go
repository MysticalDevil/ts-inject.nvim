package fixtures

func sample() {
	getUserGQL := `
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
    }
  }
  `

	createUserGQL := `
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      id
      name
    }
  }
  `

	userFieldsFragment := `
  fragment UserFields on User {
    id
    name
    email
  }
  `

	searchUsersGQL := `
  query SearchUsers($query: String!, $includeInactive: Boolean!) {
    activeUsers: users(query: $query, status: ACTIVE) {
      ...UserFields
    }
    inactiveUsers: users(query: $query, status: INACTIVE) @include(if: $includeInactive) {
      ...UserFields
    }
  }
  `

	getEntityGQL := `
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
  `

	_, _, _, _, _ = getUserGQL, createUserGQL, userFieldsFragment, searchUsersGQL, getEntityGQL
}
