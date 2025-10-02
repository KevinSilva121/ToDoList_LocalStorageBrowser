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
  // Define o esquema de cores para um design mais limpo
  final Color primaryColor = Colors.deepPurple;
  final Color accentColor = Colors.deepPurpleAccent.shade100;

  return Scaffold(
    // Estiliza a AppBar com o degradê
    appBar: AppBar(
      title: const Text('Minhas Tarefas ✨', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      centerTitle: true,
      backgroundColor: primaryColor,
      elevation: 0, // Remove a sombra
    ),
    
    // Adiciona um fundo mais suave
    backgroundColor: accentColor,

    body: Column(
      children: <Widget>[
        // Área de Input (A mesma lógica, mas com um padding maior)
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'Nova Tarefa',
                    hintText: 'Ex: Estudar Flutter e Dart',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addTodo(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              // Botão com formato mais moderno
              ElevatedButton(
                onPressed: () {
                  if (_taskController.text.isNotEmpty) {
                    _addTodo(_taskController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  elevation: 5,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        
        // Lista de Tarefas (Usando o Card para um visual mais atraente)
        Expanded(
          child: todos.isEmpty
              ? Center(
                  child: Text(
                    '🎉 Lista vazia! Adicione uma tarefa.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      elevation: 4, // Adiciona uma sombra agradável
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        
                        // Checkbox customizado
                        leading: Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: todo.isDone,
                            onChanged: (bool? value) => _toggleTodo(todo),
                            activeColor: primaryColor,
                            shape: const CircleBorder(),
                          ),
                        ),
                        
                        // Título da Tarefa
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: todo.isDone ? FontWeight.w500 : FontWeight.bold,
                            color: todo.isDone ? Colors.grey.shade600 : Colors.black87,
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        
                        // Ícone de Excluir
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                          onPressed: () => _removeTodo(index),
                        ),
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
