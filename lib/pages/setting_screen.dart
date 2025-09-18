import 'package:flutter/material.dart';
import 'package:ingredient_detector/components/new_item_popup.dart';
import 'package:ingredient_detector/services/preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<String> blackList = [];
  final PreferencesService _preferencesService = PreferencesService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    getBlacklist();
  }

  void _removeItem(int index) async {
    List<String> list =
        await _preferencesService.deletePreference(blackList.elementAt(index));
    final removedItem = blackList.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedItem, animation, index),
    );

    setState(() {
      blackList = list;
    });
  }

  Future<void> getBlacklist() async {
    List<String> list = await _preferencesService.readPreferences();
    setState(() {
      blackList = list;
    });
  }

  void updateBlacklist() async {
    final List<String> newList = await _preferencesService.readPreferences();

    // Find new items added (simple example assumes 1 new item at end)
    final newItems =
        newList.where((item) => !blackList.contains(item)).toList();

    for (final item in newItems) {
      blackList.add(item);
      final index = blackList.length - 1;
      _listKey.currentState?.insertItem(index);
    }

    setState(() {
      blackList = newList;
    });
  }

  void deletePreference(String deletedPref) async {
    List<String> list = await _preferencesService.deletePreference(deletedPref);
    setState(() {
      blackList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Saved black list items:"),
              SizedBox(
                height: 10,
              ),
              blackList.isEmpty
                  ? Text(
                      "No items selected.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Expanded(
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: blackList.length,
                        itemBuilder: (context, index, animation) {
                          final item = blackList[index];
                          return _buildItem(item, animation, index);
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 90,
        color: const Color.fromARGB(0, 255, 255, 255),
        child: SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => NewItemPopup(),
              ).then((reload) {
                if (reload) {
                  updateBlacklist();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.add),
                Text("Add item"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String item, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      axisAlignment: 0.0,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0), // Slide in from right
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // color: const Color.fromARGB(255, 201, 201, 201),
            color: const Color.fromARGB(80, 22, 205, 255),
            border: Border.all(
              color: Color.fromARGB(255, 87, 87, 87), // border color
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(item)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeItem(index),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
