import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Necessário para converter Listas para JSON

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Lista de Tarefas (Web Storage)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListScreen(),
    );
  }
}

// ------------------------------------------------------------------
// Modelo de Dados (A própria Tarefa)
// ------------------------------------------------------------------

class Todo {
  String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});

  // Converte um Objeto Todo para um Mapa (para salvar no JSON)
  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  // Cria um Objeto Todo a partir de um Mapa (para carregar do JSON)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(title: json['title'] as String, isDone: json['isDone'] as bool);
  }
}

// ------------------------------------------------------------------
// O Widget Principal (Gerenciador de Estado)
// ------------------------------------------------------------------

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // A lista que guarda as tarefas
  List<Todo> todos = [];
  final TextEditingController _taskController = TextEditingController();
  static const String _todoListKey = 'todo_list'; // Chave para o Local Storage

  @override
  void initState() {
    super.initState();
    _loadTodos(); // Tenta carregar as tarefas ao iniciar
  }

  // --------------------------------------------------
  // Funções de Persistência (Salvar/Carregar)
  // --------------------------------------------------

  // Carrega a lista de tarefas do Local Storage
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_todoListKey);

    if (todosString != null) {
      // 1. Decodifica o JSON para uma Lista de Mapas
      final List<dynamic> decodedList = jsonDecode(todosString);
      // 2. Converte a Lista de Mapas para uma Lista de Objetos Todo
      setState(() {
        todos = decodedList.map((map) => Todo.fromJson(map)).toList();
      });
    }
  }

  // Salva a lista de tarefas no Local Storage
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Converte a Lista de Objetos Todo para uma Lista de Mapas
    final List<Map<String, dynamic>> todosMapList = todos
        .map((todo) => todo.toJson())
        .toList();
    // 2. Codifica a Lista de Mapas para uma string JSON
    final String todosString = jsonEncode(todosMapList);
    // 3. Salva a string JSON no Local Storage
    await prefs.setString(_todoListKey, todosString);
  }

  // --------------------------------------------------
  // Funções de Ação (Adicionar/Remover/Concluir)
  // --------------------------------------------------

  void _addTodo(String title) {
    setState(() {
      todos.add(Todo(title: title));
    });
    _saveTodos();
    _taskController.clear();
  }

  void _toggleTodo(Todo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    _saveTodos();
  }

  void _removeTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
    _saveTodos();
  }

  // --------------------------------------------------
  // Interface de Usuário
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas121'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Nova Tarefa',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _addTodo(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      _addTodo(_taskController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (bool? value) {
                      _toggleTodo(todo);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTodo(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
