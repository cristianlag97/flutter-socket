

class Band {
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    required this.votes
  });

  factory Band.fromMap(Map<String, dynamic> obj) => Band(
    id: obj['id'] ?? 'no.id',
    name: obj['name'] ?? 'no-name',
    votes: obj['votes'] ?? 0
  );


}

// TODO:  factory constructor no es mas que un constructor que recibe cierto tipo de argumentos y regresa una nueva instancia de la clase