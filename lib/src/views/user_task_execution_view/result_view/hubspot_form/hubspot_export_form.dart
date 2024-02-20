import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/hubspot_manager/hubspot_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../DS/design_system.dart' as ds;
import '../../../../../DS/theme/themes.dart';
import '../../../../models/language/system_language.dart';
import 'object_association_tiles.dart';

class HubspotExportForm extends StatefulWidget {
  final HubspotFormManager hubspotFormManager;
  HubspotExportForm({required this.hubspotFormManager, super.key});

  @override
  State<HubspotExportForm> createState() => _HubspotExportFormState();
}

class _HubspotExportFormState extends State<HubspotExportForm> {
  bool _sending = false;
  bool _successfullSent = false;
  TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    final textColor = themeProvider.themeMode == ThemeMode.dark
        ? ds.DesignColor.grey.grey_1
        : ds.DesignColor.grey.grey_9;
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? ds.DesignColor.grey.grey_7
            : ds.DesignColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ds.Spacing.largePadding),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(ds.Spacing.mediumPadding),
                child: Text('Hubspot',
                    style: TextStyle(
                        fontSize: ds.TextFontSize.h2, color: textColor)),
              ),
              Row(
                children: [
                  Text(
                      labelsProvider.getText(
                          key:
                              "userTaskExecution.resultTab.hubspotIntegration.saveAs"),
                      style: TextStyle(
                        fontSize: ds.TextFontSize.body2,
                        color: textColor,
                      )),
                  DropdownButton<String>(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                    value: widget.hubspotFormManager.engagementType,
                    items: HubspotFormManager.availableEngagementTypes
                        .map((engagementType) => DropdownMenuItem(
                              value: engagementType,
                              child: Text(engagementType,
                                  style: TextStyle(
                                    fontSize: ds.TextFontSize.body2,
                                    color: textColor,
                                  )),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        widget.hubspotFormManager.engagementType = value!;
                      });
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                  ),
                  Text(
                      labelsProvider.getText(
                          key:
                              "userTaskExecution.resultTab.hubspotIntegration.in"),
                      style: TextStyle(
                        fontSize: ds.TextFontSize.body2,
                        color: textColor,
                      )),
                ],
              ),
            ]
              ..addAll(HubspotObjectType.values.map((objectType) {
                final selectedObjectType =
                    widget.hubspotFormManager.selectedObjectType;
                if (selectedObjectType == null ||
                    selectedObjectType == objectType) {
                  return AssociatedObjectTile(
                      objectType, widget.hubspotFormManager, onSubmitted: () {
                    setState(() {
                      widget.hubspotFormManager.selectedObjectType = null;
                      widget.hubspotFormManager.associatedObject = null;
                      widget.hubspotFormManager.clearSuggestions();
                      // remove focus from textfield
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  }, onSelected: (HubspotObjectType value) {
                    setState(() {
                      widget.hubspotFormManager.selectedObjectType = value;
                    });
                  },
                      textController: selectedObjectType == objectType
                          ? _textController
                          : null,
                      focusNode:
                          selectedObjectType == objectType ? _focusNode : null);
                }
                return Container();
              }))
              ..add(
                // export button
                _sending
                    ? Padding(
                        padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: ds.DesignColor.primary.main),
                        ),
                      )
                    : _successfullSent
                        ? ds.DesignIcon.checkBig(
                            color: ds.DesignColor.status.success,
                            size: ds.TextFontSize.h3)
                        : Opacity(
                            opacity:
                                widget.hubspotFormManager.associatedObject ==
                                        null
                                    ? 0.5
                                    : 1.0,
                            child: ds.Button.fill(
                              text: labelsProvider.getText(
                                  key:
                                      "userTaskExecution.resultTab.exportButton"),
                              onPressed: () async {
                                if (widget
                                        .hubspotFormManager.associatedObject ==
                                    null) {
                                  return;
                                }
                                setState(() {
                                  _sending = true;
                                });
                                bool success =
                                    await widget.hubspotFormManager.send();
                                if (success) {
                                  _successfullSent = true;
                                  // reset to false in 2 seconds
                                  Future.delayed(Duration(seconds: 2), () {
                                    setState(() {
                                      _successfullSent = false;
                                      widget.hubspotFormManager
                                          .associatedObject = null;
                                    });
                                  });
                                }
                                setState(() {
                                  _sending = false;
                                });
                              },
                            )),
              ),
          ),
        ),
      ),
    );
  }
}
