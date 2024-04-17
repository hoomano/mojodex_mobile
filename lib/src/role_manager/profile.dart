class Profile {
  final String name;
  final List<String> tasks;
  final int? nValidityDays;
  final int? nTasksLimit;
  final bool isFree;
  final String? productStripeId;
  final String? productAppleId;
  final String? stripePrice;

  get isFreeTrial => isFree && (nValidityDays != null || nTasksLimit != null);
  get isSubscription => nValidityDays == null && nTasksLimit == null;
  get isPackage => nTasksLimit != null;
  get description => "- ${tasks.join('\n\n- ')}";

  Profile(
      {required this.name,
      required this.tasks,
      required this.isFree,
      this.nValidityDays,
      this.nTasksLimit,
      this.productStripeId,
      this.productAppleId,
      this.stripePrice});
}
