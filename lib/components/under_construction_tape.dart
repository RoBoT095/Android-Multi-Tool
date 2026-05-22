import 'package:flutter/material.dart';

class UnderConstructionTape extends StatelessWidget {
  const UnderConstructionTape({
    super.key,
    required this.child,
    this.label = 'UNDER CONSTRUCTION',
  });

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        AbsorbPointer(child: child),

        IgnorePointer(
          child: SizedBox.expand(
            child: Center(
              child: Transform.rotate(
                angle: -0.6,
                child: Material(
                  elevation: 4,
                  color: Colors.transparent,
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Colors.black.withValues(alpha: 0.85),
                          width: 2,
                        ),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
