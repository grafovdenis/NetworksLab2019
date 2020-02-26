import 'answer_data.dart';

class QuestionData {
  final String title;
  final List<AnswerData> answers;
  final int rightAnswer;

  const QuestionData({this.title, this.answers, this.rightAnswer});
  
  Map<String, dynamic> toMap() => {
        "title": title,
        "answers": answers
            .map((answer) => {"id": answer.id, "title": answer.title})
            .toList()
      };
}
