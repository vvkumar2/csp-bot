import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // Smoother curve
    );

    _animation = Tween<double>(begin: 0.0, end: 15.0).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('learning');
  Stream _slidesStream =
      FirebaseFirestore.instance.collection('learning').snapshots();
  String _activeTopic = 'Cash-Secured Basics';
  final List<String> _topicsList = [
    'Cash-Secured Basics',
    'Risk vs. Reward',
    'Stocks & Strikes',
    'Advanced Strategies'
  ];

  void setTopicStream(String topic) {
    setState(() {
      _activeTopic = topic;
      _slidesStream =
          collection.where('topicName', isEqualTo: topic).snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 56),
      child: StreamBuilder(
        stream: _slidesStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Text('Press a button to load slides.');
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          List<dynamic> slides = docs[0]['slides'];

          return PageView.builder(
            itemCount: slides.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildTagPage(_topicsList, _activeTopic, setTopicStream,
                    _animation, context);
              }
              return _buildSlidePage(slides[index - 1]);
            },
          );
        },
      ),
    );
  }
}

_buildSlidePage(Map<String, dynamic> slide) {
  return Container(
    padding: const EdgeInsets.only(top: 30, bottom: 60, left: 20, right: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            slide['headline'],
            style: GoogleFonts.montserrat(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Center(
          child: Image.asset(
            slide['graphic'] ?? 'assets/images/test.png',
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          alignment: Alignment.center,
          child: Text(
            slide['information'],
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

_buildTagPage(
    List<String> topicsList,
    String activeTopic,
    void Function(String) setTopicStream,
    Animation<double> animation,
    BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Learn',
                  style: GoogleFonts.montserrat(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Something',
                  style: GoogleFonts.montserrat(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  'New',
                  style: GoogleFonts.montserrat(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                child: Text('TOPICS',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: topicsList
                    .map((topic) => CustomButton(
                          onPressed: () => setTopicStream(topic),
                          text: topic,
                          isActive: activeTopic == topic,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Swipe to Learn',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  // AnimatedBuilder(
                  //   animation: animation,
                  //   builder: (context, child) {
                  //     return Transform.translate(
                  //       offset: Offset(-1 * animation.value, 0),
                  //       child: child,
                  //     );
                  //   },
                  //   child: const Icon(
                  //     Icons.arrow_forward,
                  //     color: Colors.white,
                  //     size: 24,
                  //   ),
                  // ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
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
