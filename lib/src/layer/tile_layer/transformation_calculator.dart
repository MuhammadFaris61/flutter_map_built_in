import 'package:flutter_map_built_in/src/layer/tile_layer/level.dart';
import 'package:flutter_map_built_in/src/layer/tile_layer/tile_transformation.dart';
import 'package:flutter_map_built_in/src/map/flutter_map_state.dart';

class TransformationCalculator {
  final Map<double, Level> _levels = {};

  Level? levelAt(double zoom) => _levels[zoom];

  Level getOrCreateLevel(double zoom, FlutterMapState map) {
    final level = _levels[zoom];
    if (level != null) return level;

    return _levels[zoom] = Level(
      origin: map.project(map.unproject(map.pixelOrigin), zoom),
      zoom: zoom,
    );
  }

  List<double> whereLevel(bool Function(double level) test) {
    final result = <double>[];
    for (final levelZoom in _levels.keys) {
      if (test(levelZoom)) result.add(levelZoom);
    }

    return result;
  }

  void removeLevel(double levelZoom) {
    _levels.remove(levelZoom);
  }

  TileTransformation transformationFor(double levelZoom, FlutterMapState map) {
    final level = _levels[levelZoom]!;
    final scale = map.getZoomScale(map.zoom, level.zoom);
    final pixelOrigin = map.getNewPixelOrigin(map.center, map.zoom).round();
    final translate = level.origin.multiplyBy(scale) - pixelOrigin;
    return TileTransformation(scale: scale, translate: translate);
  }
}
