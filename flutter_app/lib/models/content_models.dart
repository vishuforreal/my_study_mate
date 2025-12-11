class NoteModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String course;
  final String subject;
  final String? unit;
  final String? chapter;
  final String notesFileUrl;
  final String? questionsFileUrl;
  final String? answersFileUrl;
  final bool isPaid;
  final double price;
  final int downloads;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.course,
    required this.subject,
    this.unit,
    this.chapter,
    required this.notesFileUrl,
    this.questionsFileUrl,
    this.answersFileUrl,
    this.isPaid = false,
    this.price = 0.0,
    this.downloads = 0,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      course: json['course'] ?? '',
      subject: json['subject'] ?? '',
      unit: json['unit'],
      chapter: json['chapter'],
      notesFileUrl: json['notesFileUrl'] ?? '',
      questionsFileUrl: json['questionsFileUrl'],
      answersFileUrl: json['answersFileUrl'],
      isPaid: json['isPaid'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      downloads: json['downloads'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'course': course,
      'subject': subject,
      'unit': unit,
      'chapter': chapter,
      'notesFileUrl': notesFileUrl,
      'questionsFileUrl': questionsFileUrl,
      'answersFileUrl': answersFileUrl,
      'isPaid': isPaid,
      'price': price,
      'downloads': downloads,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BookModel {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String subject;
  final String category;
  final String course;
  final String fileUrl;
  final String? coverImage;
  final bool isPaid;
  final double price;
  final int downloads;
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    required this.subject,
    required this.category,
    required this.course,
    required this.fileUrl,
    this.coverImage,
    this.isPaid = false,
    this.price = 0.0,
    this.downloads = 0,
    required this.createdAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'],
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      course: json['course'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      coverImage: json['coverImage'],
      isPaid: json['isPaid'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      downloads: json['downloads'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class TestModel {
  final String id;
  final String title;
  final String? description;
  final String subject;
  final String category;
  final String course;
  final String difficulty;
  final int duration;
  final List<QuestionModel> questions;
  final int totalMarks;
  final int passingMarks;
  final int attempts;
  final DateTime createdAt;

  TestModel({
    required this.id,
    required this.title,
    this.description,
    required this.subject,
    required this.category,
    required this.course,
    required this.difficulty,
    required this.duration,
    required this.questions,
    required this.totalMarks,
    required this.passingMarks,
    this.attempts = 0,
    required this.createdAt,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      course: json['course'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      duration: json['duration'] ?? 30,
      questions: (json['questions'] as List?)?.map((q) => QuestionModel.fromJson(q)).toList() ?? [],
      totalMarks: json['totalMarks'] ?? 100,
      passingMarks: json['passingMarks'] ?? 40,
      attempts: json['attempts'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int? correctAnswer;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.correctAnswer,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}

class PPTModel {
  final String id;
  final String title;
  final String? description;
  final String subject;
  final String category;
  final String course;
  final String fileUrl;
  final String? thumbnailUrl;
  final int downloads;
  final DateTime createdAt;

  PPTModel({
    required this.id,
    required this.title,
    this.description,
    required this.subject,
    required this.category,
    required this.course,
    required this.fileUrl,
    this.thumbnailUrl,
    this.downloads = 0,
    required this.createdAt,
  });

  factory PPTModel.fromJson(Map<String, dynamic> json) {
    return PPTModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      course: json['course'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      downloads: json['downloads'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String technology;
  final String category;
  final String difficulty;
  final String fileUrl;
  final String? thumbnailUrl;
  final List<String> tags;
  final int downloads;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.technology,
    required this.category,
    required this.difficulty,
    required this.fileUrl,
    this.thumbnailUrl,
    this.tags = const [],
    this.downloads = 0,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      technology: json['technology'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'Intermediate',
      fileUrl: json['fileUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      downloads: json['downloads'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String category;
  final String course;
  final String assignmentFileUrl;
  final String? solutionFileUrl;
  final DateTime deadline;
  final int totalMarks;
  final int downloads;
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.category,
    required this.course,
    required this.assignmentFileUrl,
    this.solutionFileUrl,
    required this.deadline,
    this.totalMarks = 100,
    this.downloads = 0,
    required this.createdAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      course: json['course'] ?? '',
      assignmentFileUrl: json['assignmentFileUrl'] ?? '',
      solutionFileUrl: json['solutionFileUrl'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now(),
      totalMarks: json['totalMarks'] ?? 100,
      downloads: json['downloads'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  bool get isOverdue => DateTime.now().isAfter(deadline);
}
