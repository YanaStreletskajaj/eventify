class Event {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String notes;
  final String repeat;
  final String reminder;

  Event({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.location = '',
    this.notes = '',
    this.repeat = 'Никогда',
    this.reminder = 'Никогда',
  });
}