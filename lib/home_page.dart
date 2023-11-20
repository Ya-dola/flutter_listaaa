import 'package:flutter/cupertino.dart';
import 'package:listaaa/ListScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Listaaa'),
      ),
      child: ListScreen(),
    );
  }
}
