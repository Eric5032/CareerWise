// import 'package:flutter/material.dart';
// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// class JobPage extends StatefulWidget {
//   const JobPage({
//     Key? key,
//     required this.jobTitle
//   }) : super(key: key);
//
//   final String jobTitle;
//
//   @override
//   State<JobPage> createState() => _JobPageState();
// }
//
// class _JobPageState extends State<JobPage> {
//   late final OpenAI _openAI;
//   String? tips;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState(); // Only call this once at the top
//
//     _openAI = OpenAI.instance.build(
//       token: dotenv.env['OPENAI_API_KEY'],
//       baseOption: HttpSetup(
//         receiveTimeout: const Duration(seconds: 30),
//       ),
//     );
//
//     getRiskFactor();
//   }
//
//   Future<void> getRiskFactor() async {
//     final prompt =
//         "give me risk factors for ${widget.jobTitle} from low medium and high"
//         "give 4 points as to why thats the risk factor. 35 words each";
//
//     final request = ChatCompleteText(
//         messages: [
//           {"role": "user", "content":prompt}
//         ],
//         model: Gpt4OChatModel(),
//         maxToken: 1500
//     );
//
//     final response = await _openAI.onChatCompletion(request: request);
//
//     setState(() {
//       tips = response?.choices.first.message?.content.trim();
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.jobTitle),
//       ),
//       body: Center(
//         child: isLoading ? const CircularProgressIndicator()
//         : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Container(
//             //   height: 100,
//             //   width: 100,
//             //   padding: EdgeInsets.all(16),
//             //   decoration: BoxDecoration(
//             //     color: Colors.white,
//             //     borderRadius: BorderRadius.circular(20), // rounded corners
//             //     boxShadow: [
//             //       BoxShadow(
//             //         color: Colors.black,
//             //         blurRadius: 10,
//             //         spreadRadius: 2,
//             //         offset: Offset(0, 4), // horizontal, vertical offset
//             //       ),
//             //     ],
//             //   ),
//             //   child:
//             //     ElevatedButton.icon(
//             //       onPressed: () {
//             //         // Your save action
//             //       },
//             //       icon: Icon(Icons.save),
//             //       label: Text("Save"),
//             //   ),
//             // ),
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20), // rounded corners
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black,
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                     offset: Offset(0, 4), // horizontal, vertical offset
//                   ),
//                 ],
//               ),
//               child: Text(tips ?? "No tips"),
//             ),
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white, // white container
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black, // black shadow
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey[200], // light gray background for the text field
//                   hintText: "Enter Your Question Here: ",
//                   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15), // rounded text field
//                     borderSide: BorderSide.none, // no visible border
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       )
//
//     );
//   }
// }