import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Hello World Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(child: Text('Hello World')),
    );
  }
}


/*
This code creates a simple "Hello World" Flutter application. Here's a breakdown:

*   **`import 'package:flutter/material.dart';`**: This line imports the Flutter Material Design library, which provides pre-built UI components.

*   **`void main() { runApp(const MyApp()); }`**:  This is the entry point of the application. The `runApp()` function inflates the `MyApp` widget and attaches it to the screen.

*   **`class MyApp extends StatelessWidget { ... }`**: This defines the root widget of the application, `MyApp`. It's a `StatelessWidget` because its state doesn't change.

    *   **`@override Widget build(BuildContext context) { ... }`**: The `build` method describes how the widget should be rendered.
    *   **`return MaterialApp(...)`**: The `MaterialApp` widget configures the overall look and feel of the application using Material Design.
        *   `title`: Sets the title of the app (used by the operating system).
        *   `theme`: Defines the app's theme (e.g., primary color).  Here, it's set to blue.
        *   `home`: Sets the home screen of the application to `MyHomePage`.

*   **`class MyHomePage extends StatefulWidget { ... }`**:  This defines the home page of the application. It's a `StatefulWidget` because it holds state (`_MyHomePageState`) that can change.

    *   **`MyHomePage({Key? key, required this.title}) : super(key: key);`**:  The constructor for `MyHomePage`, taking a `title` as a required argument.
    *   **`final String title;`**: Declares the `title` property, which is immutable after initialization.
    *   **`@override State<MyHomePage> createState() => _MyHomePageState();`**: Creates the state object (`_MyHomePageState`) associated with this widget.

*   **`class _MyHomePageState extends State<MyHomePage> { ... }`**: This is the state object for the `MyHomePage` widget.

    *   **`@override Widget build(BuildContext context) { ... }`**:  The `build` method for the state object.
    *   **`return Scaffold(...)`**: The `Scaffold` widget provides the basic visual structure for the app screen.
        *   `appBar`:  An app bar at the top of the screen.
            *   `title`: Displays the title passed from `MyHomePage`.
        *   `body`: The main content of the screen.
            *   `Center`: Centers its child widget.
                *   `Text('Hello World')`: Displays the text "Hello World".

In essence, this code creates an application with a blue app bar and the text "Hello World" centered on the screen.
*/
