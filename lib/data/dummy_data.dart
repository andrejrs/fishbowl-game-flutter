
final List<String> dummyPlayerNames = [
  'Alice',
  'Bob',
  'Charlie',
  'Diana',
  'Ethan',
  'Fiona',
  'George',
  'Hannah',
  'Ivan',
  'Julia',
];

final Map<String, List<String>> dummyPlayerWords = {
  'Alice': ['apple', 'art', 'arcade'],
  'Bob': ['banana', 'boat', 'book'],
  'Charlie': ['cat', 'car', 'cake'],
  'Diana': ['dog', 'desk', 'door'],
  'Ethan': ['egg', 'engine', 'earth'],
  'Fiona': ['fish', 'forest', 'fork'],
  'George': ['grape', 'game', 'garden'],
  'Hannah': ['hat', 'house', 'horse'],
  'Ivan': ['ice', 'island', 'idea'],
  'Julia': ['juice', 'jungle', 'jacket'],
};

// Example: choose one user (e.g., "Alice")
final String user = 'Alice';

// Count that user's words safely
final int totalWordsPerUser = dummyPlayerWords[user]?.length ?? 0;