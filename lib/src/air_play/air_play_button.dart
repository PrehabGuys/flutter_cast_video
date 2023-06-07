part of flutter_cast_video;

final AirPlayPlatform _airPlayPlatform = AirPlayPlatform.instance;
int? _id;

Future<bool> isAirplayConnected(int id) => _id != null
    ? Future.value(false)
    : _airPlayPlatform.invokeIsAirplayConnected(id: _id!);

/// Widget that displays the AirPlay button.
class AirPlayButton extends StatelessWidget {
  /// Creates a widget displaying a AirPlay button.
  AirPlayButton({
    Key? key,
    this.size = 30.0,
    this.color = Colors.black,
    this.activeColor = Colors.white,
    this.onRoutesOpening,
    this.onRoutesClosed,
    this.onPlayerStateChanged,
    this.onConnectionStateChange,
    this.checkConnectionEverySecond,
  }) : super(key: key);

  /// The size of the button.
  final double size;

  /// The color of the button.
  final Color color;

  /// The color of the button when connected.
  final Color activeColor;

  /// Called while the AirPlay popup is opening.
  final VoidCallback? onRoutesOpening;

  /// Called when the AirPlay popup has closed.
  final VoidCallback? onRoutesClosed;

  final Function? onPlayerStateChanged;

  //Checks connection state every checkConnectionEverySecond value (Default is every 2 seconds)
  final Function(bool)? onConnectionStateChange;
  final int? checkConnectionEverySecond;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = {
      'red': color.red,
      'green': color.green,
      'blue': color.blue,
      'alpha': color.alpha,
      'activeRed': activeColor.red,
      'activeGreen': activeColor.green,
      'activeBlue': activeColor.blue,
      'activeAlpha': activeColor.alpha,
    };
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: size,
        height: size,
        child: _airPlayPlatform.buildView(args, _onPlatformViewCreated),
      );
    }
    return SizedBox();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    await _airPlayPlatform.init(id);

    if (onRoutesOpening != null) {
      _airPlayPlatform
          .onRoutesOpening(id: id)
          .listen((_) => onRoutesOpening!());
    }
    if (onRoutesClosed != null) {
      _airPlayPlatform
          .onRoutesClosed(id: id)
          .listen((event) => onRoutesClosed!());
    }
    if (onPlayerStateChanged != null) {
      _airPlayPlatform.isAirplayConnected(id: id).listen((event) {
        onPlayerStateChanged!.call(event.connected);
      });
    }
    if (onConnectionStateChange != null) {
      _connectionStateChecker(
          id: id,
          callback: onConnectionStateChange!,
          duration: checkConnectionEverySecond);
    }
  }
}

void _connectionStateChecker(
    {required int id, required Function(bool) callback, int? duration}) {
  bool lastKnowState = false;
  Timer.periodic(Duration(seconds: duration ?? 2), (timer) {
    _airPlayPlatform.invokeIsAirplayConnected(id: id).then((value) {
      if (value == lastKnowState) return;
      debugPrint("Airplay id: $id | Is connected: $value");
      callback(value);
      lastKnowState = value;
    });
  });
}
