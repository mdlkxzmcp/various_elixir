# [Craft GraphQL APIs in Elixir with Absinthe](https://pragprog.com/book/wwgraphql/craft-graphql-apis-in-elixir-with-absinthe)
Notes.

---

## Chapter 1 – Meet GraphQL
### On the Client
The REST API is quite limiting and in essence leaves the control of what the client gets in the hands of the server. There are numerous techniques and attempts to solve this issue, but none actually solve the problem. The issue is further amplified when relationships come into play.

GraphQL specification allows the client to retrieve exacly what is needed.

A request made to a single GraphQL endpoint of:
```GraphQL
{
  user(id: 123) {
    name
    email
    friends {
      name
    }
  }
}
```
Will return the tailored JSON response of:
```JSON
{
  "data": {
    "user": {
      "name": "Lee Examp",
      "email": "lee.examp@example.com",
      "friends": [
        {"name": "Fred Only"}
      ]
    }
  }
}
```

### On the Server
A GraphQL server verifies that a request is well formated and validates that it meets the requirements defined by the schema. This gets rid of the need for special edge cases when the request is wrong, as only the validated ones get executed.
