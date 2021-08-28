import 'package:basic_application/UI/DistanceInputScreen.dart';
import 'package:basic_application/UI/HistoryOfDistance.dart';
import 'package:basic_application/bloc/Bloc/allcalls_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TabSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TabSelectorState();
}

class _TabSelectorState extends State<TabSelector> {
  int _selectedPage = 0;
  List<Widget> pageList = [];

  @override
  void initState() {
    super.initState();
    pageList.add(DistanceInputScreen());
    pageList.add(HistoryOfDistance());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocProvider(
      create: (context) => AllcallsBloc(),
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0.25,
                  blurRadius: 3,
                  offset: Offset(0, -5), // changes position of shadow
                ),
              ],
            ),
            child: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.pinned,
              currentIndex: _selectedPage,
              backgroundColor: Colors.white,
              snakeShape: SnakeShape.indicator,
              selectedItemColor: Color.fromRGBO(129, 187, 46, 1),
              unselectedItemColor: Color.fromRGBO(101, 101, 101, 1),
              snakeViewColor: Color.fromRGBO(129, 187, 46, 1),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle:
                  TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
              unselectedLabelStyle:
                  TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
              shadowColor: Colors.black,
              onTap: (pageNumber) {
                setState(() {
                  _selectedPage = pageNumber;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Column(children: [
                      SvgPicture.asset(
                        "assets/distance.svg",
                        height: 25,
                        color: _selectedPage == 0
                            ? Color.fromRGBO(129, 187, 46, 1)
                            : Color.fromRGBO(101, 101, 101, 1),
                      ),
                      SizedBox(
                        height: 3,
                      )
                    ]),
                    label: "Measure Distance"),
                BottomNavigationBarItem(
                  icon: Column(children: [
                    SvgPicture.asset(
                      "assets/history.svg",
                      height: 25,
                      color: _selectedPage == 1
                          ? Color.fromRGBO(129, 187, 46, 1)
                          : Color.fromRGBO(101, 101, 101, 1),
                    ),
                    SizedBox(
                      height: 3,
                    )
                  ]),
                  label: "History",
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedPage,
          children: pageList,
        ),
      ),
    );
  }
}
