import 'dart:convert';

import 'package:basic_application/Model/StoredLocation.dart';
import 'package:basic_application/Widgets/AllPagesAppBar.dart';
import 'package:basic_application/Widgets/ErrorMessage.dart';
import 'package:basic_application/bloc/Bloc/allcalls_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DistanceInputScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DistanceInputScreenState();
}

class _DistanceInputScreenState extends State<DistanceInputScreen> {
  late double width, newheight;
  TextEditingController textController = new TextEditingController();
  String selectedText = "", error = "";
  final bloc = new AllcallsBloc();
  final buttonBloc = new AllcallsBloc();
  @override
  void initState() {
    super.initState();
    bloc.add(getCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    Uuid tokenId = new Uuid();
    double height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    var padding = MediaQuery.of(context).padding;
    newheight = height - padding.top - padding.bottom;
    return Scaffold(
      appBar: AllPagesAppBar.appBar(context, "Measure Distance"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: Text(
                  "Your Location:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                width: width,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Color.fromRGBO(117, 117, 117, 0.7), width: 2),
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.only(top: 15, bottom: 15, left: 10),
                child: BlocBuilder(
                  bloc: bloc,
                  builder: (context, state) {
                    if (state is AllcallsInitial || state is AllcallsLoading) {
                      return Container(
                        color: Colors.white,
                      );
                    } else if (state is AllcallsLoadedWithResponse) {
                      return Text(state.response);
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: Text(
                  "Select a Location:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                child: TypeAheadFormField(
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        textController.text = suggestion.toString();
                        selectedText = suggestion.toString();
                      });
                    },
                    validator: (value) {
                      if (value != selectedText || value!.isEmpty) {
                        return "Select the suggestion that matches the street address";
                      }
                      return null;
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: textController,
                        decoration: InputDecoration(
                            fillColor: Color.fromRGBO(247, 247, 247, 1),
                            hintText: "Select a location from the suggestions",
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color.fromRGBO(13, 106, 106, 0.7),
                                )),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(117, 117, 117, 0.7),
                                  width: 2),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 10,
                            ),
                            border: OutlineInputBorder())),
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.toString()),
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      var res = await http.get(Uri.parse(
                          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${pattern}&key=AIzaSyBwqYB-60e4sDM6pLgYF6X1rbIkz-7Dt8Q&sessiontoken=${tokenId.v4()}"));
                      var next = json.decode(res.body);
                      List<String> temp = [];
                      for (int i = 0; i < next['predictions'].length; i++) {
                        temp.add(next['predictions'][i]['description']);
                      }
                      return temp;
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              ErrorMessage(error),
              SizedBox(
                height: 30,
              ),
              BlocBuilder(
                  bloc: buttonBloc,
                  builder: (context, state) {
                    if (state is AllcallsInitial ||
                        state is AllcallsLoadedWithResponse) {
                      return button();
                    } else if (state is AllcallsLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Container();
                    }
                  }),
              SizedBox(
                height: 50,
              ),
              BlocBuilder(
                  bloc: buttonBloc,
                  builder: (context, state) {
                    if (state is AllcallsInitial) {
                      return Container();
                    } else if (state is AllcallsLoadedWithResponse) {
                      return result(state.response);
                    } else if (state is AllcallsLoading) {
                      return Container();
                    } else {
                      return Container();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget button() {
    return Center(
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromRGBO(129, 187, 46, 1)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: () async {
          if (selectedText == "") {
            setState(() {
              error = "Select a location from the options provided!";
            });
          } else {
            buttonBloc.add(measureDistance(selectedText));
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Text(
                  'Measure',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget result(response) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            border:
                Border.all(color: Color.fromRGBO(129, 187, 46, 1), width: 2),
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Distance between",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              StoredLocation.currenthName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "and",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              StoredLocation.searchName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "is",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "$response km",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
