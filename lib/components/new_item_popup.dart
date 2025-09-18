import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_detector/services/preferences.dart';

class NewItemPopup extends StatefulWidget {

  const NewItemPopup({
    super.key,
  });

  @override
  State<NewItemPopup> createState() => _NewItemPopupState();
}

class _NewItemPopupState extends State<NewItemPopup> {
  final TextEditingController _textController = TextEditingController();
  bool _isCancelEnabled = false;
  final PreferencesService _preferencesService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChanged);
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {
      _isCancelEnabled = _textController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
      CupertinoAlertDialog(
      title: Text(
        "New item",
        style: TextStyle(fontSize: 22),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Please enter new item",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            
            CupertinoTextField(
              controller: _textController,
              placeholder: "Item",
              style: TextStyle(
              color: CupertinoTheme.of(context).brightness == Brightness.dark
                  ? CupertinoColors.white
                  : CupertinoColors.black,
              ),
            )
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: _textController.text.trim().isEmpty
          ? null
          : () async {
            final bool saved = await _preferencesService.savePreferences(_textController.text.toLowerCase());
            if (!context.mounted) return;
            Navigator.of(context).pop(saved);

          },
          child: Text(
            "Add",
            style: _isCancelEnabled
            ? TextStyle(color: Colors.blue)
            : TextStyle(color: const Color.fromARGB(255, 138, 138, 138))
          ),
        ),
        CupertinoDialogAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: const Color.fromARGB(255, 227, 1, 1)),
          ),
          onPressed: () => {
            Navigator.of(context).pop(false),
          },
        )
      ],

    );
  }
}