import 'package:deep_flutter/application/location/location_bloc.dart';
import 'package:deep_flutter/common/validation/input_validation.dart';
import 'package:deep_flutter/domain/location/location_req.dart';
import 'package:deep_flutter/domain/location/location_data.dart';
import 'package:deep_flutter/injection.dart';
import 'package:deep_flutter/presentation/location/widgets/dropdown_location.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationPage extends StatefulWidget {
  LocationPage({Key key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _errorMessage;

  List<DropdownMenuItem<LocationResultData>> _provinceFromListItem;
  List<DropdownMenuItem<LocationResultData>> _cityFromListItem;
  LocationResultData _selectedFromProvince;
  LocationResultData _selectedFromCity;
  String _selectedCourier;

  List<DropdownMenuItem<LocationResultData>> _provinceToListItem;
  List<DropdownMenuItem<LocationResultData>> _cityToListItem;
  LocationResultData _selectedToProvince;
  LocationResultData _selectedToCity;
  TextEditingController _weightController;
  FocusNode _weightFN;
  bool _autoValidation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _errorMessage = "";
    initializeFromData();
    initializeToData();
    _weightController = TextEditingController();
    _weightFN = FocusNode();
    _autoValidation = false;
    _selectedCourier = null;
    super.initState();
  }

  void initializeFromData() {
    _provinceFromListItem = null;
    _selectedFromProvince = null;
    _cityFromListItem = null;
    _selectedFromCity = null;
  }

  void initializeToData() {
    _provinceToListItem = null;
    _selectedToProvince = null;
    _cityToListItem = null;
    _selectedToCity = null;
  }

  void fromLocationListener(BuildContext context, LocationState state) {
    state.maybeMap(
        orElse: () {},
        cityDataOptions: (e) => e.cityProvince.fold(
            () => print("Is Loading"),
            (a) => a.fold(
                  (l) => print("Is Loading"),
                  (r) {
                    _cityFromListItem = r.results
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text("${e.type} ${e.cityName}"),
                            value: e,
                          ),
                        )
                        .toList();
                  },
                )),
        provinceDataOptions: (e) => e.dataProvince.fold(
            () => {},
            (a) => a.fold(
                  (l) {
                    l.map(
                        notFound: (e) => _errorMessage = e.msg,
                        badRequest: (e) => _errorMessage = e.badRequest,
                        serverError: (e) => _errorMessage = "Server Error");
                    FlushbarHelper.createError(message: _errorMessage)
                      ..show(context);
                  },
                  (r) {
                    _provinceFromListItem = r.results
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.province),
                            ))
                        .toList();
                  },
                )));
  }

  void toLocationListener(BuildContext context, LocationState state) {
    state.maybeMap(
        orElse: () {},
        cityDataOptions: (e) => e.cityProvince.fold(
            () => print("Is Loading"),
            (a) => a.fold(
                  (l) => print("Is Loading"),
                  (r) {
                    _cityToListItem = r.results
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text("${e.type} ${e.cityName}"),
                            value: e,
                          ),
                        )
                        .toList();
                  },
                )),
        provinceDataOptions: (e) => e.dataProvince.fold(
            () => {},
            (a) => a.fold(
                  (l) {
                    l.map(
                        notFound: (e) => _errorMessage = e.msg,
                        badRequest: (e) => _errorMessage = e.badRequest,
                        serverError: (e) => _errorMessage = "Server Error");
                    FlushbarHelper.createError(message: _errorMessage)
                      ..show(context);
                  },
                  (r) {
                    _provinceToListItem = r.results
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.province),
                            ))
                        .toList();
                  },
                )));
  }

  void _validateInputs(BuildContext context) {
    if (_formKey.currentState.validate()) {
      //berarti inputannya sudah benar

      context.bloc<LocationBloc>().add(LocationEvent.getCosts(
          fromData: _selectedFromCity,
          toData: _selectedToCity,
          weight: int.parse(_weightController.text),
          courier: _selectedCourier));
    } else {
      setState(() {
        _autoValidation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
            child: Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(shape: BoxShape.rectangle),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              //Akses Data From
              BlocProvider(
                create: (context) => getIt<LocationBloc>()
                  ..add(LocationEvent.getLocationProvince()),
                child: BlocConsumer<LocationBloc, LocationState>(
                    listener: fromLocationListener,
                    builder: (context, state) {
                      return Column(
                        children: <Widget>[
                          Text(
                            "Dari",
                            style: TextStyle(fontSize: 20),
                          ),
                          DropdownLocation<LocationResultData>(
                            hint: "Pilih Provinse",
                            dropdownItemList: _provinceFromListItem,
                            onChanged: (e) => onFromProvinceChanged(context, e),
                            selectedLocation: _selectedFromProvince,
                          ),
                          DropdownLocation<LocationResultData>(
                            hint: "Pilih City",
                            dropdownItemList: _cityFromListItem,
                            onChanged: onFromCityChanged,
                            selectedLocation: _selectedFromCity,
                          ),
                        ],
                      );
                    }),
              ),
              SizedBox(
                height: 30,
              ),

              //Akses Data To
              BlocProvider(
                create: (context) => getIt<LocationBloc>()
                  ..add(LocationEvent.getLocationProvince()),
                child: BlocConsumer<LocationBloc, LocationState>(
                    listener: toLocationListener,
                    builder: (context, state) {
                      return Column(
                        children: <Widget>[
                          Text(
                            "To",
                            style: TextStyle(fontSize: 20),
                          ),
                          DropdownLocation<LocationResultData>(
                            hint: "Pilih Provinsi",
                            dropdownItemList: _provinceToListItem,
                            onChanged: (e) => onToProvinceChanged(context, e),
                            selectedLocation: _selectedToProvince,
                          ),
                          DropdownLocation<LocationResultData>(
                            hint: "Pilih City",
                            dropdownItemList: _cityToListItem,
                            onChanged: onToCityChanged,
                            selectedLocation: _selectedToCity,
                          ),
                        ],
                      );
                    }),
              ),
              SizedBox(
                height: 30,
              ),

              Form(
                key: _formKey,
                autovalidate: _autoValidation,
                child: TextFormField(
                    onFieldSubmitted: (value) => {_weightFN.unfocus()},
                    keyboardType: TextInputType.number,
                    controller: _weightController,
                    focusNode: _weightFN,
                    validator: checkInputIsEmpty,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 3)),
                        hintText: "Weight gram",
                        suffixText: "gram")),
              ),
              SizedBox(
                height: 20,
              ),
              DropdownLocation<String>(
                hint: "Pilih Jenis Pengiriman",
                dropdownItemList: [
                  DropdownMenuItem(child: Text("JNE"), value: "jne"),
                  DropdownMenuItem(child: Text("POS"), value: "pos"),
                  DropdownMenuItem(child: Text("TIKI"), value: "tiki"),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCourier = value;
                  });
                },
                selectedLocation: _selectedCourier,
              ),
              SizedBox(
                height: 20,
              ),

              BlocProvider(
                create: (context) => getIt<LocationBloc>(),
                child: BlocListener<LocationBloc, LocationState>(
                  listener: (context, state) {
                    state.maybeMap(
                      orElse: () {},
                      costsDataOptions: (value) => value.costData.fold(
                          () => {},
                          (a) => a.fold(
                              (l) => print("error"),
                              (r) => showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                        title: Text("Hasil Pencarian"),
                                        children: (r.results.length == 0 ||
                                                r.results.isEmpty)
                                            ? [Text("No Data Shown")]
                                            : r.results[0].costs
                                                .map((e) =>
                                                    listItemOfServices(e))
                                                .toList());
                                  }))),
                    );
                  },
                  child: BlocBuilder<LocationBloc, LocationState>(
                      builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      height: 40,
                      child: RaisedButton(
                        child: Text("Get All Data"),
                        onPressed: () {
                          print("From" + _selectedFromCity.toString());
                          print("To" + _selectedToCity.toString());
                          _validateInputs(context);
                        },
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget listItemOfServices(Costs e) => ListTile(
        title: Text(e.service),
        trailing: Text(e.cost[0].value.toString()),
        subtitle: Text(e.cost[0].etd.toString() + " Hari"),
      );

  void onFromCityChanged(LocationResultData data) {
    setState(() {
      _selectedFromCity = data;
    });
  }

  void onFromProvinceChanged(BuildContext context, LocationResultData data) {
    setState(() {
      _selectedFromProvince = data;
      _selectedFromCity = null;
      _cityFromListItem = null;
    });

    context
        .bloc<LocationBloc>()
        .add(LocationEvent.getLocationCity(provinceId: data.provinceId));
  }

  void onToCityChanged(LocationResultData data) {
    setState(() {
      _selectedToCity = data;
    });
  }

  void onToProvinceChanged(BuildContext context, LocationResultData data) {
    setState(() {
      _selectedToProvince = data;
      _selectedToCity = null;
      _cityToListItem = null;
    });

    context
        .bloc<LocationBloc>()
        .add(LocationEvent.getLocationCity(provinceId: data.provinceId));
  }

  Container nullDataProvince() {
    return Container(child: Text("Tidak ada yang ditampilkan"));
  }

  Container noneDataGetProvinceWidget() {
    return Container(
      child: Text("datanya NONE"),
    );
  }

  Expanded successGetProvinceWidget(ProvinceResponse r) {
    return Expanded(
        child: ListView.builder(
            itemCount: r.results.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(r.results[index].province),
              );
            }));
  }

  Container locationLoadingWidget() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Expanded errorGetProvinceWidget(String message) {
    return Expanded(
      child: Container(
        child: Text(message),
      ),
    );
  }
}

//  return Container(
//                     child: Column(
//                       children: <Widget>[
//                         state.maybeMap(
//                             orElse: () => (_provinceResponse == null)
//                                 ? nullDataProvince()
//                                 : successGetProvinceWidget(_provinceResponse),
//                             provinceDataOptions: (e) {
//                               if (e.onLoading) {
//                                 return locationLoadingWidget();
//                               } else {
//                                 return e.dataProvince.fold(
//                                     () => noneDataGetProvinceWidget(), (a) {
//                                   return a.fold(
//                                     (l) =>
//                                         errorGetProvinceWidget(_errorMessage),
//                                     (r) => successGetProvinceWidget(
//                                         _provinceResponse),
//                                   );
//                                 });
//                               }
//                             }),
//                       ],
//                     ),
//                   );
