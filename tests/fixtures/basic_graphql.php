<?php

$getUserGql = <<<'GQL'
      query GetUser {
        user {
          id
          name
          email
        }
      }
    GQL;

$createUserGql = <<<'GQL'
      mutation CreateUser {
        createUser {
          id
          name
          email
        }
      }
    GQL;

$userUpdatedGql = <<<'GQL'
      subscription OnUserUpdated {
        userUpdated {
          id
          name
          status
        }
      }
    GQL;

$userFieldsGql = <<<'GQL'
      fragment UserFields on User {
        id
        name
        email
      }
    GQL;

$searchUsersGql = <<<'GQL'
      query SearchUsers {
        activeUsers: users(status: ACTIVE) {
          ...UserFields
        }
        inactiveUsers: users(status: INACTIVE) @include(if: true) {
          ...UserFields
        }
      }
    GQL;

$getEntityGql = <<<'GQL'
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
    GQL;
