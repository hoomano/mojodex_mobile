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
  Future<List<HubspotObject>>? _suggestionsFuture;

  Future<List<HubspotObject>> _searchSuggestions(String query) async {
    print("searchSuggestions");
    // Call the actual search method with the given query and
    // process the response. This might depend on your actual implementation.
    // Here I assumed it returns a list of strings.
    List<HubspotObject> suggestionList =
        await widget.hubspotFormManager.search(query, widget.object);
    return suggestionList;
  }

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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: widget.object.singularName,
              // icon at the end
              suffixIcon: Visibility(
                visible: widget.hubspotFormManager.associatedObject != null,
                child: IconButton(
                  icon: ds.DesignIcon.closeSM(
                      size: ds.TextFontSize.body2,
                      color: ds.DesignColor.grey.grey_9),
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
                setState(() {
                  _suggestionsFuture = _searchSuggestions(value);
                });
              }
            },
          ),
          if (widget.hubspotFormManager.selectedObjectType != null)
            SizedBox(
                height: 200,
                child: Visibility(
                  visible: widget.hubspotFormManager.associatedObject == null,
                  child: FutureBuilder(
                    future: _suggestionsFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<HubspotObject>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding:
                              const EdgeInsets.all(ds.Spacing.smallPadding),
                          child: Center(
                            child: LinearProgressIndicator(
                              color: ds.DesignColor.primary.main,
                              backgroundColor:
                                  themeProvider.themeMode == ThemeMode.dark
                                      ? ds.DesignColor.grey.grey_5
                                      : ds.DesignColor.grey.grey_3,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        List<HubspotObject> suggestions = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: suggestions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(suggestions[index].name),
                              onTap: () {
                                setState(() {
                                  widget.textController?.text =
                                      suggestions[index].name;
                                  widget.hubspotFormManager.associatedObject =
                                      suggestions[index];
                                });
                              },
                            );
                          },
                        );
                      } else {
                        return Container(); // Empty container if no suggestions
                      }
                    },
                  ),
                )),
        ],
      ),
    );
  }
}
