import 'package:auto_route/auto_route.dart';
import 'package:deep_flutter/application/location/location_bloc.dart';
import 'package:deep_flutter/injection.dart';
import 'package:deep_flutter/presentation/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomPage extends StatefulWidget {
  HomPage({Key key}) : super(key: key);

  @override
  _HomPageState createState() => _HomPageState();
}

class _HomPageState extends State<HomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Kambing"),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                ExtendedNavigator.of(context).push(Routes.locationPage);
              },
              child: Text("Tekan Akuh"),
            ),
          ],
        ));
  }
}
