
class StoryLine {
  final String speaker;
  final String text;
  final String portrait;

  const StoryLine({
    required this.speaker,
    required this.text,
    required this.portrait,
  });
}

const List<StoryLine> storyData = [
  StoryLine(
    speaker: 'آرین',
    text: 'امروز هم یک روز جدید شروع شده. باید زودتر مغازه را باز کنم.',
    portrait: 'arian_portrait.png',
  ),
  StoryLine(
    speaker: 'مادر',
    text: 'آرین جان، صبحانه‌ات را بخور. امروز برنامه مهمی داری.',
    portrait: 'mother_portrait.png',
  ),
  StoryLine(
    speaker: 'آرین',
    text: 'نگران نباش مامان، همه چیز را مدیریت می‌کنم.',
    portrait: 'arian_portrait.png',
  ),
  StoryLine(
    speaker: 'مادر',
    text: 'مواظب خودت باش پسرم.',
    portrait: 'mother_portrait.png',
  ),
];
