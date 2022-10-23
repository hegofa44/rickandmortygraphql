import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
  const charactersGraphQl = """
  query characters{
     characters(page: 1) {
    results {
      name
      status
      species
      image
      origin{
        name 
        
      }
    }
  }
}
""";
void main() {

  final HttpLink httpLink = HttpLink("https://rickandmortyapi.com/graphql/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: InMemoryStore()
      ),
      ),
  );
  var app = GraphQLProvider(
    client: client,
    child: MyApp(),
  );
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Rick and Morty'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
       body: Query(
          options: QueryOptions(
            document: gql(charactersGraphQl),),
          builder: (QueryResult result, {fetchMore, refetch}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final characterList = result.data?['characters']['results'];
            // print(characterList);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Characters', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),), 
                ),
                // SizedBox(height: 40,),
                Expanded(
                  child: GridView.builder(
                    
                    itemCount: characterList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 2.0,
                      childAspectRatio: 0.9,
                      crossAxisCount: 2,
                      ),
                    itemBuilder: (context, index) {
                      
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Stack(
                                children: [
                                  Image.network(
                                    characterList[index]['image'],
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(10.0),),
                                      color: (characterList[index]['status'] == 'Alive')?Colors.green:(characterList[index]['status'] == 'Dead')?Colors.red:Colors.amber
                                    ),
                                    child: Text(characterList[index]['status']),
                                  ),
                                  
                                  Positioned(
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0),bottomRight: Radius.circular(10.0),),
                                        color: Colors.black45
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(characterList[index]['species'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          Text(characterList[index]['origin']['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                            color: Colors.grey[300],
                            ),
                            width: double.infinity,
                            child: Text(characterList[index]['name']),
                          )
                        ],
                      );
                    },
                  )
                )
              ],
            );

          }),
        );
  }
}