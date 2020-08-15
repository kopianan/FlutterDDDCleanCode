import 'package:dartz/dartz.dart';
import 'package:deep_flutter/domain/location/location_failure.dart';
import 'package:deep_flutter/domain/location/location_interface.dart';
import 'package:deep_flutter/domain/location/location_req.dart';
import 'package:deep_flutter/domain/location/location_data.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: LocationInterface)
class LocationRepository extends LocationInterface {
  Dio dio;
  LocationRepository(this.dio);

  @override
  Future<Either<LocationFailure, ProvinceResponse>>
      getAllLocationFromRajaOngkir() async {
    dio = Dio();
    Response response;
    try {
      response = await dio.get("https://api.rajaongkir.com/starter/province",
          options:
              Options(headers: {"key": "d3378ccdaa201c0b0bffbd673aab43c2"}));
      final _result = response.data['rajaongkir'];

      final data = ProvinceResponse.fromJson(_result);
      return right(data);
    } on DioError catch (err) {
      switch (err.response.statusCode) {
        case 400:
          final errorData = err.response.data['rajaongkir']['status'];
          final data = LocationStatusData.fromJson(errorData);
          return left(LocationFailure.badRequest(data.description));
          break;
        case 404:
          return left(LocationFailure.notFound("Not Found"));
        default:
          return left(LocationFailure.serverError());
          break;
      }
    }
    ;
  }

  @override
  Future<Either<LocationFailure, CityResponse>> getCityByProvinceId(
      {String provinceId}) async {
    dio = Dio();
    Response response;
    try {
      response = await dio.get("https://api.rajaongkir.com/starter/city",
          queryParameters: {"province": "$provinceId"},
          options:
              Options(headers: {"key": "d3378ccdaa201c0b0bffbd673aab43c2"}));
      final _result = response.data['rajaongkir'];

      final data = CityResponse.fromJson(_result);
      return right(data);
    } on DioError catch (err) {
      switch (err.response.statusCode) {
        case 400:
          final errorData = err.response.data['rajaongkir']['status'];
          final data = LocationStatusData.fromJson(errorData);
          return left(LocationFailure.badRequest(data.description));
          break;
        case 404:
          return left(LocationFailure.notFound("Not Found"));
        default:
          return left(LocationFailure.serverError());
          break;
      }
    }
  }

  @override
  Future<Either<LocationFailure, CostResponse>> getCost(
      {LocationResultData fromData,
      LocationResultData toData,
      int weight,
      String courier}) async {
    dio = Dio();
    Response response;
    try {
      response = await dio.post("https://api.rajaongkir.com/starter/cost",
          data: {
            "origin": fromData.cityId.toString(),
            "destination": toData.cityId.toString(),
            "weight": weight.toString(),
            "courier": courier
          },
          options:
              Options(headers: {"key": "d3378ccdaa201c0b0bffbd673aab43c2"}));
      final _result = response.data['rajaongkir'];

      final data = CostResponse.fromJson(_result);
      print(data.results.length.toString() + "Panjang Ongkos kirim");
      return right(data);
    } on DioError catch (err) {
      switch (err.response.statusCode) {
        case 400:
          final errorData = err.response.data['rajaongkir']['status'];
          final data = LocationStatusData.fromJson(errorData);
          return left(LocationFailure.badRequest(data.description));
          break;
        case 404:
          return left(LocationFailure.notFound("Not Found"));
        default:
          return left(LocationFailure.serverError());
          break;
      }
    }
  }
}
