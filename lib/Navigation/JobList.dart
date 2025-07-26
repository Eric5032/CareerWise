import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../OpenAI/job_page.dart';

class PopUp extends StatelessWidget {
  const PopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

enum Dropdown1 {
  o1("Most Viewed"),
  o2("Least Risk"),
  o3("Highest Risk");

  const Dropdown1(this.options);
  final String options;

  static final List<DropdownMenuEntry<Dropdown1>> entries =
  UnmodifiableListView<DropdownMenuEntry<Dropdown1>>(
    values.map<DropdownMenuEntry<Dropdown1>>(
          (Dropdown1 items) => DropdownMenuEntry<Dropdown1>(
        value: items,
        label: items.options,
        enabled: true,
        style: MenuItemButton.styleFrom(foregroundColor: Colors.grey),
      ),
    ),
  );
}

enum Dropdown2 {
  r1("1"),
  r2("2"),
  r3("3"),
  r4("4"),
  r5("5");

  const Dropdown2(this.rating);
  final String rating;

  static final List<DropdownMenuEntry<Dropdown2>> entries =
  UnmodifiableListView<DropdownMenuEntry<Dropdown2>>(
    values.map<DropdownMenuEntry<Dropdown2>>(
          (Dropdown2 items) => DropdownMenuEntry<Dropdown2>(
        value: items,
        label: items.rating,
        enabled: true,
        style: MenuItemButton.styleFrom(foregroundColor: Colors.grey),
      ),
    ),
  );
}

class MyJobList extends StatefulWidget {
  const MyJobList({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MyJobList> createState() => JobList();
}

class JobList extends State<MyJobList> {
  Dropdown1? selectedRelevancy = Dropdown1.o1;
  Dropdown2? selectedRating = Dropdown2.r1;
  final TextEditingController colorController = TextEditingController();
  final TextEditingController iconController = TextEditingController();

  final List<Map<String, dynamic>> jobData = [
    {
      'imageUrl': 'https://example.com/image1.jpg',
      'jobTitle': 'Developer',
      'tags': ['Test'],
    },
    {
      'imageUrl': 'https://example.com/image2.jpg',
      'jobTitle': 'Designer',
      'tags': ['Test'],
    },
    // ... 10 more entries
  ];
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Dropdown Row Container
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownMenu<Dropdown1>(
                    initialSelection: Dropdown1.o1,
                    controller: colorController,
                    label: const Text('Relevancy'),
                    onSelected: (Dropdown1? items) {
                      setState(() {
                        selectedRelevancy = items;
                      });
                    },
                    dropdownMenuEntries: Dropdown1.entries,
                  ),
                ),
                Expanded(
                  child: DropdownMenu<Dropdown2>(
                    initialSelection: Dropdown2.r1,
                    controller: colorController,
                    label: const Text('Rating'),
                    onSelected: (Dropdown2? items) {
                      setState(() {
                        selectedRating = items;
                      });
                    },
                    dropdownMenuEntries: Dropdown2.entries,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Items Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(jobData.length, (index) {
              final job = jobData[index];
              return JobsTemplate(
                imageUrl: job['imageUrl'],
                JobTitle: job['jobTitle'],
                tags: List<String>.from(job['tags']),
              );
            }),
          ),

          const SizedBox(height: 40), // padding at the bottom
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const PopUp();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class JobsTemplate extends StatelessWidget {
  final String imageUrl;
  final String JobTitle;
  List<String> tags;

  JobsTemplate(
      {required this.imageUrl, this.JobTitle = "Title", this.tags = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Image(
                image: NetworkImage(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
              child: TextButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobPage(jobTitle: JobTitle,))
                  );
                },
                child: Text(JobTitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
