give me step by step code and instruction to implement this project i am usign firebase (firestore-database and realtime-database) databases

i allready connect and setup the code the firebase to my project now give me the file and code to implenment the project  

At TaskFlow Solutions, our users currently juggle between typing and tapping to add, update,
or complete to-do items, leading to interruptions during busy routines, missed tasks, and
friction when hands-free operation is needed (e.g., cooking, driving). To deliver a seamless,
accessible experience, we need a Flutter-based Voice-Driven To-Do List App that lets users
manage their tasks entirely by speaking, with natural‐language understanding for creating,
editing, and querying tasks. The app must support offline voice capture—queuing commands
locally—and automatically synchronise with a cloud backend once connectivity is restored. It
should provide real-time sync across devices, so a task added on one phone instantly appears
on another, and give users audible confirmations and prompts for ambiguous commands. Your
task is to develop a working prototype that solves these challenges while following Flutter best
practices for state management, offline caching, and audio processing.
Key Pain Points to Solve:
 Interruptions to workflow when hands are busy cause users to postpone or forget task
entry.
 Inaccurate or incomplete task entries due to manual typing errors.
Lack of offline voice support makes the feature unreliable in low-connectivity scenarios.
Sync conflicts or delays occur when switching devices without immediate internet
access.
The ideal solution will balance the accuracy of speech recognition, responsiveness in offline

and online modes, and a clean, conversational UI while demonstrating maintainable, well-
structured code.

Note:
 Voice Command Parsing: Use an on-device speech-to-text engine with a fallback to
cloud recognition for improved accuracy.
 Offline Queueing: Store spoken commands locally (e.g., in SQLite or Hive) and replay
to the cloud backend on reconnection.
 Real-Time Sync: Leverage a backend like Firebase Realtime Database or Firestore with
conflict-resolution rules for multi-device updates.
 User Feedback: Provide TTS or in-app audio cues confirming task addition, completion,
or prompting for clarification.
 Data Persistence: Implement robust caching and state management (e.g., Riverpod,
Bloc) to ensure smooth UX.


dont use any other database like (e.g., in SQLite or Hive)