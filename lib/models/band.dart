

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
    id: obj['id'],
    name: obj['name'],
    votes: obj['votes']
  );


}

// TODO:  factory constructor no es mas que un constructor que recibe cierto tipo de argumentos y regresa una nueva instancia de la clase