import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SimpleBlocDelegate extends BlocDelegate {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    analytics.logEvent(
      name: '${bloc}_$event',
    );
    print('$bloc:$event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(bloc);
    print(error);
    print(stacktrace);
  }
}
