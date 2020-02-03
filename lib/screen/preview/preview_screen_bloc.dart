import 'package:chika_scan/screen/preview/preview_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreviewScreenBloc extends Bloc<PreviewScreenEvent, PreviewScreenState> {
  @override
  String toString() => "プレビュー画面";

  @override
  PreviewScreenState get initialState => UninitializedState();

  @override
  Stream<PreviewScreenState> mapEventToState(PreviewScreenEvent event) async* {
    // 初期化要求
    if (event is OnRequestInitializingEvent) {
      yield InitializingState();

      yield InitializedState();
    }

    // 描画完了
    else if (event is OnCompleteRenderingEvent) {
      yield IdlingState();
    }
  }
}
