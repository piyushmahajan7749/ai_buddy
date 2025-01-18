// ignore_for_file: lines_longer_than_80_chars

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
    title: 'Aap ka personal real estate assistant',
    description:
        '9Roof aap ka ek personal assistant hai, jo aapko property search karne me help karta hai.',
  ),
  IntroStep(
    title: 'Aap ka Network hi aap ki Networth hai',
    description:
        '9Roof aapko apni city ke 1000s of realtors se instantly connect karwa deta hai.',
  ),
  IntroStep(
    title: 'Har client ke liye right property',
    description:
        '9Roof ke paas sabse bada property listing database hai. Aapko har client ke liye right property milti hai.',
  ),
  IntroStep(
    title: 'Aapki 10x Growth unlocked',
    description:
        'AI ki help se \n better network + better properties = 10x growth in your business.',
  ),
];
