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
  // Variable declarations
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPageIndex = 0;
  String _activeTopic = 'Cash-Secured Basics';
  int _activeTopicIndex = 0;

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('learning');
  Stream? _slidesStream = FirebaseFirestore.instance
      .collection('learning')
      .where('topicName', isEqualTo: 'Cash-Secured Basics')
      .snapshots();
  final List<String> _topicsList = [
    'Cash-Secured Basics',
    'Risk vs. Reward',
    'Stocks & Strikes',
    'Advanced Strategies'
  ];

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Lifecycle methods
  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPageIndex != next) {
        setState(() {
          _currentPageIndex = next;
        });
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic, // Smoother curve
    );

    _animation = Tween<double>(begin: 0.0, end: 15.0).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setTopicStream(String topic) {
    setState(() {
      _activeTopicIndex = _topicsList.indexOf(topic);
      _activeTopic = topic;
      _slidesStream =
          collection.where('topicName', isEqualTo: topic).snapshots();
    });
  }

  void startArrowAnimation() {
    _animationController.forward().then((_) => _animationController.reverse());
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
            controller: _pageController,
            itemCount: slides.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildTagPage(_topicsList, _activeTopic, setTopicStream,
                    _animation, startArrowAnimation, context);
              }
              return _buildSlidePage(
                slides[index - 1],
                index == _currentPageIndex,
                _currentPageIndex,
              );
            },
          );
        },
      ),
    );
  }

  _buildSlidePage(Map<String, dynamic> slide, bool active, int index) {
    final double top = active ? 75 : 150;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 30, right: 10, left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(31, 25, 31, 0.6 - _activeTopicIndex * 0.4),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 21, 21, 21).withOpacity(0.1),
            spreadRadius: 8,
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Image.network(
                      slide['graphic'] ?? "https://picsum.photos/200/300",
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    slide['headline'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    slide['information'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '$index',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildTagPage(
      List<String> topicsList,
      String activeTopic,
      void Function(String) setTopicStream,
      Animation<double> animation,
      void Function() startArrowAnimation,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Learn',
                    style: GoogleFonts.poppins(
                      fontSize: 58,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Something',
                    style: GoogleFonts.poppins(
                      fontSize: 58,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'New',
                    style: GoogleFonts.poppins(
                      fontSize: 58,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.1,
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
                  child: Text('CHOOSE A TOPIC',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topicsList
                      .map((topic) => CustomButton(
                            onPressed: () {
                              setTopicStream(topic);
                              startArrowAnimation();
                            },
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
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(-1 * animation.value, 0),
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
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
