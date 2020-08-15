import 'package:auto_route/auto_route_annotations.dart';
import 'package:deep_flutter/presentation/home/home_page.dart';
import 'package:deep_flutter/presentation/location/location_page.dart';

@MaterialAutoRouter(routes: [
  MaterialRoute(page: HomPage, initial: true),
  MaterialRoute(
    page: LocationPage,
  ),
])
class $Router {}
