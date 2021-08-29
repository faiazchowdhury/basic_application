import 'package:basic_application/Model/ListOfHistory.dart';
import 'package:basic_application/Widgets/AllPagesAppBar.dart';
import 'package:basic_application/bloc/Bloc/allcalls_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryOfDistance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HistoryOfDistanceState();
}

class _HistoryOfDistanceState extends State<HistoryOfDistance> {
  late double newheight, width;
  final bloc = new AllcallsBloc();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController chatController = new TextEditingController();

  void _onRefresh() async {
    bloc.add(getListOfHistory());
  }

  @override
  void initState() {
    super.initState();
    bloc.add(getListOfHistory());
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    var padding = MediaQuery.of(context).padding;
    newheight = height - padding.top - padding.bottom;
    return Scaffold(
      appBar: AllPagesAppBar.appBar(context, "History"),
      body: Container(
          height: newheight,
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) {
              if (state is AllcallsInitial || state is AllcallsLoading) {
                return Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CircularProgressIndicator()),
                  ),
                );
              } else if (state is AllcallsLoadedWithResponse) {
                return viewScreen(state.response);
              } else {
                return Container();
              }
            },
          )),
    );
  }

  Widget viewScreen(var res) {
    return res.length == 0
        ? Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "No records to show!",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(13, 106, 106, 0.29)),
              ),
            ),
          )
        : SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: WaterDropHeader(
              waterDropColor: Color.fromRGBO(129, 187, 46, 1),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
                itemCount: res.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      width: width,
                      height: 110,
                      child: Card(
                          elevation: 2,
                          margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "${res[index]['current_place']}",
                                              textAlign: TextAlign.start,
                                              textScaleFactor: 0.9,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      32, 32, 32, 1)),
                                            ),
                                          )),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "To",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        32, 32, 32, 1)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${res[index]['searched_place']}",
                                                textScaleFactor: 0.9,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        32, 32, 32, 1)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Distance",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      32, 32, 32, 1)),
                                            ),
                                          )),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${res[index]['distance']} km",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color.fromRGBO(
                                                        32, 32, 32, 1)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                              Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      bloc.add(
                                          removeEntry(res[index]['docId']));
                                    },
                                    child: Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.horizontal(
                                              right: Radius.circular(5)),
                                        ),
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        )),
                                  ))
                            ],
                          )));
                }));
  }
}
