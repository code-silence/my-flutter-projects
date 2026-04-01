import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const apiKey = String.fromEnvironment('GEMINI_API_KEY');

const personalityPrompt = """
You are Roxy, a friendly anime girl assistant who lives with the user in a cozy room.

You speak in a warm, playful, mature girl tone like a helpful anime girl companion.

Rules:
- Never say you are an AI, language model, or Gemini.
- Never mention Google or APIs.
- Speak naturally like a real assistant girl.
- Be supportive, friendly, and a little playful.
- Keep replies conversational.
- Always give user informative information on what user asks.

Your name is Roxy.
""";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String emotion = "normal";
  double girlWidth = 700;
  double girlHeight = 500;

  TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];

  bool isLoading = false; // 🔥 NEW

  late final GenerativeModel model;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateEmotion(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("happy") ||
        lower.contains("great") ||
        lower.contains("love")) {
      emotion = "happy";
    } else if (lower.contains("sad") ||
        lower.contains("bad") ||
        lower.contains("sorry")) {
      emotion = "sad";
    } else if (lower.contains("cry") ||
        lower.contains("tears") ||
        lower.contains("angry")) {
      emotion = "cry";
    } else {
      emotion = "normal";
    }
  }

  Future<void> askGemini() async {

    if (controller.text.trim().isEmpty) return;

    String userMessage = controller.text;

    setState(() {
      messages.add({"role": "user", "text": userMessage});
      isLoading = true; // 🔥 START LOADING
    });

    controller.clear();

    try {

      List<Content> conversation = [
        Content.text(personalityPrompt)
      ];

      for (var msg in messages) {
        conversation.add(Content.text(msg["text"]!));
      }

      final response = await model.generateContent(conversation);
      final text = response.text ?? "No reply";

      setState(() {
        messages.add({"role": "emily", "text": text});
        updateEmotion(text);
        isLoading = false; 
      });

    } catch (e) {
      setState(() {
        messages.add({"role": "emily", "text": "Error: $e"});
        isLoading = false;
      });
    }
  }

  Widget chatBubble(Map<String, String> message) {

    bool isUser = message["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color: isUser
              ? const Color.fromARGB(255, 243, 251, 175)
              : Colors.black54,
          borderRadius: BorderRadius.circular(15),
        ),
        child: MarkdownBody(
          data: message["text"]!,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: isUser ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget thinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          "Roxy is thinking...",
          style: TextStyle(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 6,
        centerTitle: true,
        title: const Text(
          "Chat with Roxy",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 243, 251, 175),
          ),
        ),
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/living room.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            left: -10,
            bottom: 20,
            child: Image.asset(
              "assets/images/girl_$emotion.png",
              width: girlWidth,
              height: girlHeight,
              fit: BoxFit.fill,
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: screenWidth * 0.70,
                child: Column(
                  children: [

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {

                          if (isLoading && index == messages.length) {
                            return thinkingBubble(); // 🔥 HERE
                          }

                          return chatBubble(messages[index]);
                        },
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.fromLTRB(
                        10,
                        10,
                        10,
                        MediaQuery.of(context).viewInsets.bottom + 10,
                      ),
                      color: Colors.black54,
                      child: Row(
                        children: [

                          Expanded(
                            child: TextField(
                              controller: controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Let's talk!",
                                hintStyle:
                                    TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.black54,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onSubmitted: (_) => askGemini(),
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            onPressed: askGemini,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 243, 251, 175),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Send"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}