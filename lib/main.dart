import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(GraphQLSubscriptionDemo());
}

class GraphQLSubscriptionDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      uri: 'https://counter.hasura.app/v1/graphql',
    );

    final WebSocketLink websocketLink = WebSocketLink(
      url: 'wss://counter.hasura.app/v1/graphql',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink.concat(websocketLink),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text("Graphql Subscription Demo"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                IncrementButton(),
                SizedBox(height: 3, child: Container(color: Colors.green)),
                Counter()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IncrementButton extends StatelessWidget {
  static String incr = '''mutation IncrementCounter {
  update_counter(
    where: {id: {_eq: 1}},
    _inc: {count: 1}
  ) {
    affected_rows
    returning {
      id
      count
    }
  }
}''';

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        documentNode: gql(incr),
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return Center(
          child: RaisedButton.icon(
            onPressed: () {
              runMutation({});
            },
            icon: Icon(Icons.plus_one),
            label: Text(""),
          ),
        );
      },
    );
  }
}

class Counter extends StatelessWidget {
  static String subscription = '''subscription WatchCounter {
  counter(where: {id: {_eq: 1}}) {
    count
  }
}''';

  @override
  Widget build(BuildContext context) {
    return Subscription(
      "WatchCounter",
      subscription,
      builder: ({
        bool loading,
        dynamic payload,
        dynamic error,
      }) {
        if (payload != null) {
          return Text(payload['counter'][0]['count'].toString());
        } else {
          return Text("Fetching Online Users");
        }
      },
    );
  }
}
