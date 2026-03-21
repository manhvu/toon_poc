# Client

```elixir
Client.Worker.start_link()

# for push data to server
Client.Worker.push("push_data", [1, 3, %{a: 1}])

# get data from server
Client.Worker.get_data()
```
