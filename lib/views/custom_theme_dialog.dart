import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomThemeDialog extends StatefulWidget {
  final Color currentPrimary;
  final Color currentAccent;
  final Color currentBackground;

  const CustomThemeDialog({
    Key? key,
    required this.currentPrimary,
    required this.currentAccent,
    required this.currentBackground,
  }) : super(key: key);

  @override
  _CustomThemeDialogState createState() => _CustomThemeDialogState();
}

class _CustomThemeDialogState extends State<CustomThemeDialog> {
  late Color _primaryColor;
  late Color _accentColor;
  late Color _backgroundColor;
  String _themeName = '';

  @override
  void initState() {
    super.initState();
    _primaryColor = widget.currentPrimary;
    _accentColor = widget.currentAccent;
    _backgroundColor = widget.currentBackground;
  }

  void _showColorPicker(BuildContext context, String colorType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn màu ${colorType == 'primary' ? 'chính' : colorType == 'accent' ? 'phụ' : 'nền'}'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: colorType == 'primary' 
                  ? _primaryColor 
                  : colorType == 'accent' 
                      ? _accentColor 
                      : _backgroundColor,
              onColorChanged: (color) {
                setState(() {
                  if (colorType == 'primary') {
                    _primaryColor = color;
                  } else if (colorType == 'accent') {
                    _accentColor = color;
                  } else {
                    _backgroundColor = color;
                  }
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Xong'),
            ),
          ],
        );
      },
    );
  }

  bool _validateTheme() {
    return _themeName.isNotEmpty &&
        _themeName.toLowerCase() != 'pink' &&
        _primaryColor != Colors.transparent &&
        _accentColor != Colors.transparent &&
        _backgroundColor != Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo Theme Tùy Chỉnh'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Tên Theme',
                hintText: 'Nhập tên theme',
                errorText: _themeName.toLowerCase().contains('pink') 
                    ? 'Không được dùng tên "Pink"'
                    : null,
              ),
              onChanged: (value) => setState(() => _themeName = value),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Màu chính'),
              trailing: Container(
                width: 50,
                height: 30,
                color: _primaryColor,
              ),
              onTap: () => _showColorPicker(context, 'primary'),
            ),
            ListTile(
              title: const Text('Màu phụ'),
              trailing: Container(
                width: 50,
                height: 30,
                color: _accentColor,
              ),
              onTap: () => _showColorPicker(context, 'accent'),
            ),
            ListTile(
              title: const Text('Màu nền'),
              trailing: Container(
                width: 50,
                height: 30,
                color: _backgroundColor,
              ),
              onTap: () => _showColorPicker(context, 'background'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _themeName.isEmpty ? null : () {
            Navigator.pop(context, {
              'name': _themeName,
              'primary': _primaryColor,
              'accent': _accentColor,
              'background': _backgroundColor,
            });
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
