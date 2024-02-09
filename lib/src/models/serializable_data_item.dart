abstract class SerializableDataItem {
  int? pk;
  SerializableDataItem(this.pk);
  Map<String, dynamic> toJson();
  SerializableDataItem.fromJson(Map<String, dynamic> json);
}
