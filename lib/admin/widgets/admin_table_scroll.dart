import 'package:flutter/material.dart';

/// Wraps a DataTable so it (1) scrolls vertically when there are many rows,
/// (2) scrolls horizontally when the screen is too narrow for all columns,
/// and (3) stretches to fill the available width instead of leaving empty
/// space when the screen is wider than the table's natural size.
class AdminTableScroll extends StatelessWidget {
  final DataTable table;
  const AdminTableScroll({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 32),
              child: table,
            ),
          ),
        );
      },
    );
  }
}