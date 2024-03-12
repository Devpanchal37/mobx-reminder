import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobx_reminder/loading/loading_screen_controller.dart';
import 'package:mobx_reminder/loading/spin_kit_chasing_dots.dart';

class LoadingScreen {
  // This is a private constructor for the LoadingScreen class.
  LoadingScreen._sharedInstance();
  // This line declares a static final variable _shared of type LoadingScreen and
  // initializes it with the result of calling the private constructor _sharedInstance().
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  // This is a factory constructor named instance() which returns an instance of the LoadingScreen class.
  // Instead of creating a new instance every time it's called,
  // it returns the same instance stored in the _shared variable.
  // This ensures that only one instance of LoadingScreen is ever created, making it a singleton
  factory LoadingScreen.instance() => _shared;

  LoadingScreenController? controller;

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final _text = StreamController<String>();
    _text.add(text);
    // the Overlay widget is a powerful tool for displaying content such as floating widgets,
    // pop-ups, or visual effects, on top of other content in a widget tree.
    // The Overlay widget itself does not have direct access to its state. Instead, to interact with the Overlay and its state,
    // you typically use the Overlay.of(context) method.
    final state = Overlay.of(context);
    // It will allow you to extract available size that overlay can have on the screen
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child:
                // SpinKitChasingDots(color: Colors.red, size: 50 ?? 50)
                Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        stream: _text.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
//This add the overlay to the entire overlay state that flutter manages on the screen
    state.insert(overlay);
// return close and update function because it's required
    return LoadingScreenController(
      close: () {
        _text.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        _text.add(text);
        return true;
      },
    );
  }
}
