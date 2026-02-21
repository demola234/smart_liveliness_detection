import 'dart:math' as math;

extension DoubleClamp on double {
  double clamp01() => this < 0.0 ? 0.0 : (this > 1.0 ? 1.0 : this);
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t.clamp01();

// Simple 2D vector for particle physics
class Vec2 {
  double x, y;
  Vec2(this.x, this.y);
  Vec2.zero() : x = 0, y = 0;
  Vec2 copy() => Vec2(x, y);
  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);
  double get length => math.sqrt(x * x + y * y);
  Vec2 normalized() {
    double l = length;
    if (l < 1e-6) return Vec2.zero();
    return Vec2(x / l, y / l);
  }

  void add(Vec2 other) {
    x += other.x;
    y += other.y;
  }
}
