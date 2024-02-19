import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../DS/design_system.dart' as ds;
import '../../../../../DS/theme/themes.dart';
import '../../../../hubspot_manager/hubspot_manager.dart';

class AssociatedObjectTile extends StatefulWidget {
  HubspotFormManager hubspotFormManager;
  Function onSelected;
  Function onSubmitted;
  TextEditingController? textController;
  late final FocusNode focusNode = FocusNode();
  AssociatedObjectTile(this.object, this.hubspotFormManager,
      {required this.onSubmitted,
      required this.onSelected,
      this.textController,
      bool focus = false}) {
    if (focus) {
      focusNode.requestFocus();
    }
  }
  HubspotObjectType object;

  @override
  State<AssociatedObjectTile> createState() => _AssociatedObjectTileState();
}

class _AssociatedObjectTileState extends State<AssociatedObjectTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.themeMode == ThemeMode.dark
        ? ds.DesignColor.grey.grey_1
        : ds.DesignColor.grey.grey_9;
    return Padding(
      padding: const EdgeInsets.only(top: ds.Spacing.largePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Set to min to wrap content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            focusNode: widget.focusNode,
            controller: widget.textController,
            readOnly: widget.hubspotFormManager.associatedObject != null,
            style: TextStyle(
              color: textColor,
              fontSize: ds.TextFontSize.body2,
            ),
            cursorColor: ds.DesignColor.primary.main,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: ds.DesignColor.grey.grey_5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ds.DesignColor.primary.main),
              ),
              labelText: widget.object.singularName,
              labelStyle: TextStyle(
                color: textColor,
                fontSize: ds.TextFontSize.body2,
              ),
              // icon at the end
              suffixIcon: Visibility(
                visible: widget.hubspotFormManager.associatedObject != null,
                child: IconButton(
                  icon: ds.DesignIcon.closeSM(
                      size: ds.TextFontSize.body2, color: textColor),
                  onPressed: () {
                    setState(() {
                      widget.textController?.clear();
                      widget.hubspotFormManager.associatedObject = null;
                    });
                  },
                ),
              ),
            ),
            onSubmitted: (String value) {
              widget.textController?.clear();
              widget.onSubmitted();
            },
            onTap: () {
              if (widget.hubspotFormManager.selectedObjectType == null) {
                widget.onSelected(widget.object);
              }
            },
            onChanged: (String value) {
              if (widget.hubspotFormManager.associatedObject == null) {
                widget.hubspotFormManager.search(value, widget.object);
              }
            },
          ),
          if (widget.hubspotFormManager.selectedObjectType != null)
            SizedBox(
                height: 200,
                child: Visibility(
                  visible: widget.hubspotFormManager.associatedObject == null,
                  child: ValueListenableBuilder(
                      valueListenable:
                          widget.hubspotFormManager.searchingNotifier,
                      builder: (BuildContext context, bool searching, _) {
                        return searching
                            ? Padding(
                                padding: const EdgeInsets.all(
                                    ds.Spacing.smallPadding),
                                child: Center(
                                  child: LinearProgressIndicator(
                                    color: ds.DesignColor.primary.main,
                                    backgroundColor: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? ds.DesignColor.grey.grey_5
                                        : ds.DesignColor.grey.grey_3,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget
                                    .hubspotFormManager.suggestions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final suggestion = widget
                                      .hubspotFormManager.suggestions[index];
                                  return ListTile(
                                    title: Text(
                                      suggestion.name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: ds.TextFontSize.body2,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        widget.textController?.text =
                                            suggestion.name;
                                        widget.hubspotFormManager
                                            .associatedObject = suggestion;
                                      });
                                    },
                                  );
                                },
                              );
                      }),
                )),
        ],
      ),
    );
  }
}
