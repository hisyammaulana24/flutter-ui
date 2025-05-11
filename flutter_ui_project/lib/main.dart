import 'package:flutter/material.dart';

// Import semua file yang ingin dipanggil
import '1-basic-widget/button.dart';
import '2-layout/1_column.dart';
import '2-layout/2_row.dart';
import '2-layout/3_listview.dart';
import '2-layout/4_gridview.dart';
import '2-layout/5_padding.dart';
import '2-layout/6_aspecratio.dart';
import '2-layout/7_center.dart';
import '2-layout/8_sizedbox.dart';
import '2-layout/9_wrap.dart';

import '3-form/1_textfield.dart';
import '3-form/2_dropdown.dart' as dropdown;
import '3-form/3_switch.dart' as switch_widget;
import '3-form/4_radio.dart' as radio_widget;
import '3-form/5_checkbox.dart' as checkbox_widget;
import '3-form/6_datapicker.dart' as datepicker_widget;
import '3-form/7_dialog.dart' as dialog_widget;
import '3-form/8_bottomsheet.dart' as BottomSheetWidget;
import '3-form/9_snackbar.dart' as SnackbarWidget;

import '4-navigator/1_navigator.dart';
import '4-navigator/2_bottomnavigationbar.dart';
import '4-navigator/3_tabBar.dart';
import '4-navigator/4_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Widget>> pages = [
      {'Button (Basic)': const ButtonWidget()},
      {'Column': const Kolom()},
      {'Row': const Baris()},
      {'ListView': ListViewWidget()},
      {'GridView': const GridViewWidget()},
      {'Padding': const PaddingWidget()},
      {'AspectRatio': const AspectRatioWidget()},
      {'Center': const CenterWidget()},
      {'SizedBox': const SizedBoxWidget()},
      {'Wrap': WrapWidget()},

      {'TextField': const MyTextField()},
      {'Dropdown': const dropdown.MyDropDown()},
      {'Switch': const switch_widget.MyDropDown()},
      {'Radio': const radio_widget.MyDropDown()},
      {'Checkbox': const checkbox_widget.MyDropDown()},
      {'DatePicker': const datepicker_widget.MyDropDown()},
      {'Dialog': const dialog_widget.MyDropDown()},
      {'BottomSheet': const BottomSheetWidget.MyDropDown()},
      {'Snackbar': const SnackbarWidget.MyDropDown()},

      {'Navigator': NavigatorWidget()},
      {'BottomNavBar': BottomNavBarWidget()},
      {'TabBar': TabBarWidget()},
      {'Drawer': DrawerWidget()},
      {'SliverAppBar': const SliverAppBar()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter UI Demo')),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final title = pages[index].keys.first;
          final widget = pages[index].values.first;
          return ListTile(
            title: Text(title),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget),
              );
            },
          );
        },
      ),
    );
  }
}