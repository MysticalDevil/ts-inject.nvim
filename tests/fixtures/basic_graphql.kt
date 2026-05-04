fun main() {
    val GET_USER_GQL =
        """
        query GetUser {
          user {
            id
            name
            email
          }
        }
        """.trimIndent()

    val createUserGql =
        """
        mutation CreateUser {
          createUser {
            id
            name
            email
          }
        }
        """.trimIndent()

    val userUpdatedGql =
        """
        subscription OnUserUpdated {
          userUpdated {
            id
            name
            status
          }
        }
        """.trimIndent()

    val userFieldsGql =
        """
        fragment UserFields on User {
          id
          name
          email
        }
        """.trimIndent()

    val searchUsersGql =
        """
        query SearchUsers {
          activeUsers: users(status: ACTIVE) {
            ...UserFields
          }
          inactiveUsers: users(status: INACTIVE) @include(if: true) {
            ...UserFields
          }
        }
        """.trimIndent()

    val getEntityGql =
        """
        query GetEntity {
          entity {
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
        """.trimIndent()

    println(GET_USER_GQL)
    println(createUserGql)
    println(userUpdatedGql)
    println(userFieldsGql)
    println(searchUsersGql)
    println(getEntityGql)
}
