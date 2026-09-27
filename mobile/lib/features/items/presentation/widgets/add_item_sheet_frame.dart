import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../cubit/items/add_item_cubit.dart';
import 'add_item_sheet_header.dart';

/// The bottom-sheet card: header, scrollable body, and a [footer] pinned below.
class AddItemSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget footer;

  const AddItemSheetFrame({
    super.key,
    required this.title,
    required this.child,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddItemCubit, AddItemState>(
      listener: (context, state) {
        if (state is AddItemSuccess) {
          Navigator.of(context).pop(state.item);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: ZaytonaSpacing.space3),
            AddItemSheetHeader(
              title: title,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  ZaytonaSpacing.space5,
                  ZaytonaSpacing.space1,
                  ZaytonaSpacing.space5,
                  ZaytonaSpacing.space4,
                ),
                child: child,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZaytonaSpacing.space5,
                ZaytonaSpacing.space0,
                ZaytonaSpacing.space5,
                ZaytonaSpacing.space5,
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}
