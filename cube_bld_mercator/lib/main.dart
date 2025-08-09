import 'package:flutter/material.dart';
import 'controllers/world_controller.dart';
import 'models/defs.dart';
import 'widgets/cube_world.dart';
import 'widgets/selected_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rubik Mercator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B0F18), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rubik Mercator Grid'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WorldController controller;

  @override
  void initState() {
    super.initState();
    controller = WorldController(defsRef: defs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Reset View',
            onPressed: () {
              controller.resetView();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Scene
            Expanded(child: CubeWorld(controller: controller)),
            const SizedBox(height: 12),
            // Selected stickers bar
            Align(
              alignment: Alignment.centerLeft,
              child: SelectedBar(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
