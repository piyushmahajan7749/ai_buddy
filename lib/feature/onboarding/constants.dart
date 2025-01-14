class IntroStep {
  IntroStep({
    required this.title,
    required this.description,
    this.image,
  });
  final String title;
  final String description;
  final String? image;
}

class Review {
  Review({
    required this.title,
    required this.description,
  });
  final String title;
  final String description;
}

List<IntroStep> introSteps = [
  IntroStep(
    title: 'Search Smarter, Not Harder',
    description:
        // ignore: lines_longer_than_80_chars
        'Use the power of AI and find the properties you are looking for, in seconds.',
  ),
  IntroStep(
    title: 'Connect Instantly',
    description:
        // ignore: lines_longer_than_80_chars
        'Direct access to property owners and real estate agents. Schedule viewings and get responses in real-time.',
  ),
  IntroStep(
    title: 'Unlock Your 10x Growth',
    description:
        // ignore: lines_longer_than_80_chars
        "List your properties and get connected with thousands of potential buyers and tenants. It's fast, easy, and free.",
  ),
];
