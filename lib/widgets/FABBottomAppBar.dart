import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';

class FABBottomAppBarItem {
    FABBottomAppBarItem({this.iconPath, this.text});
    String iconPath;
    String text;
}

class FABBottomAppBar extends StatefulWidget {
    FABBottomAppBar({
        this.items,
        this.centerItemText,
        this.height: 60.0,
        this.iconSize: 24.0,
        this.backgroundColor,
        this.color,
        this.selectedColor,
        this.notchedShape,
        this.onTabSelected,
    }) {
        assert(this.items.length == 2 || this.items.length == 4);
    }
    final List<FABBottomAppBarItem> items;
    final String centerItemText;
    final double height;
    final double iconSize;
    final Color backgroundColor;
    final Color color;
    final Color selectedColor;
    final NotchedShape notchedShape;
    final ValueChanged<int> onTabSelected;

    @override
    State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
    int _selectedIndex = Constants.homeSplashIndex;
    bool showNotification = false;

    void _updateIndex(int index) {
        if (_selectedIndex == 0 && index == 0) {
            Constants.eventBus.fire(new ScrollToTopEvent(tabIndex: index, type: widget.items[index].text));
        }
        widget.onTabSelected(index);
        setState(() {
            _selectedIndex = index;
        });
    }

    @override
    void initState() {
        super.initState();
        Constants.eventBus
            ..on<ActionsEvent>().listen((event) {
                if (mounted) {
                    setState(() {
                        if (event.type == "action_home") {
                            _selectedIndex = 0;
                        } else if (event.type == "action_apps") {
                            _selectedIndex = 1;
                        } else if (event.type == "action_discover") {
                            _selectedIndex = 2;
                        } else if (event.type == "action_user") {
                            _selectedIndex = 3;
                        }
                    });
                }
            })
            ..on<NotificationsChangeEvent>().listen((event) {
                if (mounted) {
                    setState(() {
                        if (event.notifications.count != 0) {
                            showNotification = true;
                        } else {
                            showNotification = false;
                        }
                    });
                }
            });
    }

    @override
    Widget build(BuildContext context) {
        List<Widget> items = List.generate(widget.items.length, (int index) {
            return _buildTabItem(
                item: widget.items[index],
                index: index,
                onPressed: _updateIndex,
            );
        });
        items.insert(items.length >> 1, _buildMiddleTabItem());

        Widget appBar = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items,
        );

        if (Platform.isIOS) {
            appBar = ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: Constants.suSetSp(20.0), sigmaY: Constants.suSetSp(20.0)),
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(top: BorderSide(
                                color: Color.fromARGB(255, 169, 169, 169),
                            )),
                        ),
                        child: appBar,
                    ),
                ),
            );
        }

        return BottomAppBar(
            color: widget.backgroundColor,
            shape: widget.notchedShape,
            child: appBar,
        );
    }

    Widget _buildMiddleTabItem() {
        return Expanded(
            child: SizedBox(
                height: widget.height,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        SizedBox(height: widget.iconSize),
                        Text(
                            widget.centerItemText ?? '',
                            style: TextStyle(color: widget.color),
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _buildTabItem({
        FABBottomAppBarItem item,
        int index,
        ValueChanged<int> onPressed,
    }) {
        Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
        String iconPath = "assets/icons/bottomNavigation/${item.iconPath}-${_selectedIndex == index ? "fill" : "line"}.svg";
        return Expanded(
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onPressed(index),
                child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                        SizedBox(
                            height: Constants.suSetSp(widget.height),
                            child: Material(
                                type: MaterialType.transparency,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        SvgPicture.asset(
                                            iconPath,
                                            color: color,
                                            width: Constants.suSetSp(widget.iconSize),
                                            height: Constants.suSetSp(widget.iconSize),
                                        ),
                                        Text(
                                            item.text,
                                            style: TextStyle(
                                                color: color,
                                                fontSize: Constants.suSetSp(16.0),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Visibility(
                            visible: showNotification && index == 2,
                            child: Positioned(
                                top: Constants.suSetSp(5),
                                right: Constants.suSetSp(28),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Constants.suSetSp(5)),
                                    child: Container(
                                        width: Constants.suSetSp(10),
                                        height: Constants.suSetSp(10),
                                        color: widget.selectedColor,
                                    ),
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}