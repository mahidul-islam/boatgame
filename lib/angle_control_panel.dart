import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'angle_game.dart'; // For AngleGame and InputMode enum

class AngleControlPanel extends StatefulWidget {
  final AngleGame game;

  const AngleControlPanel({super.key, required this.game});

  @override
  State<AngleControlPanel> createState() => _AngleControlPanelState();
}

class _AngleControlPanelState extends State<AngleControlPanel> {
  final TextEditingController _angleController = TextEditingController();
  double _sliderAngle = 0.0;
  // No need for local _currentMode if we use ValueNotifier from game
  // InputMode _currentMode = InputMode.manual;

  @override
  void initState() {
    super.initState();
    // Initialize UI state from game state
    _sliderAngle = widget.game.currentAngleNotifier.value;
    _angleController.text = _sliderAngle.toStringAsFixed(0);
    // _currentMode = widget.game.currentInputModeNotifier.value;

    // Listen to angle changes from the game (e.g., during drag or reset)
    widget.game.currentAngleNotifier.addListener(_updateAngleFromGame);
    // Listen to mode changes from the game
    widget.game.currentInputModeNotifier.addListener(_updateModeFromGame);
  }

  @override
  void dispose() {
    widget.game.currentAngleNotifier.removeListener(_updateAngleFromGame);
    widget.game.currentInputModeNotifier.removeListener(_updateModeFromGame);
    _angleController.dispose();
    super.dispose();
  }

  void _updateAngleFromGame() {
    if (mounted) {
      final gameAngle = widget.game.currentAngleNotifier.value;
      setState(() {
        _sliderAngle = gameAngle;
        // Only update text field if it doesn't have focus to avoid disrupting user input
        if (!FocusScope.of(context).hasFocus ||
            _angleController.text != gameAngle.toStringAsFixed(0)) {
          _angleController.text = gameAngle.toStringAsFixed(0);
        }
      });
    }
  }

  void _updateModeFromGame() {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild, showing/hiding relevant controls
        // _currentMode = widget.game.currentInputModeNotifier.value;
      });
    }
  }

  void _onAngleChangedByUI(double newAngle) {
    newAngle = newAngle.clamp(0.0, 360.0);
    if (newAngle == 360.0) newAngle = 0.0; // Normalize 360 to 0

    setState(() {
      _sliderAngle = newAngle;
      _angleController.text = newAngle.toStringAsFixed(0);
    });
    // In manual mode, optionally provide live rotation preview
    // if (widget.game.currentInputModeNotifier.value == InputMode.manual) {
    //   widget.game.setBoatAngle(newAngle);
    // }
  }

  void _onTextFieldSubmitted(String value) {
    final newAngle = double.tryParse(value);
    if (newAngle != null) {
      _onAngleChangedByUI(newAngle);
    } else {
      // Reset text field to current slider angle if input is invalid
      _angleController.text = _sliderAngle.toStringAsFixed(0);
    }
    FocusScope.of(context).unfocus(); // Dismiss keyboard
  }

  @override
  Widget build(BuildContext context) {
    // Use ValueListenableBuilder to react to mode changes from the game
    return ValueListenableBuilder<InputMode>(
      valueListenable: widget.game.currentInputModeNotifier,
      builder: (context, currentMode, child) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        currentMode == InputMode.manual
                            ? Icons.mouse
                            : Icons.drag_handle,
                      ),
                      onPressed: () {
                        widget.game.toggleInputMode();
                      },
                      label: Text(
                        currentMode == InputMode.manual
                            ? "Manual Input"
                            : "Drag Mode",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      widget.game.resetGame();
                      // Angle Notifier in game will update UI values
                    },
                    label: const Text("Reset"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (currentMode == InputMode.manual) ...[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _angleController,
                        decoration: const InputDecoration(
                          labelText: "Angle",
                          hintText: "0-360°",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onSubmitted: _onTextFieldSubmitted,
                        onEditingComplete: () =>
                            _onTextFieldSubmitted(_angleController.text),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5, // Give slider more space
                      child: Slider(
                        value: _sliderAngle,
                        min: 0,
                        max: 360,
                        divisions: 360, // Snap to whole degrees
                        label: "${_sliderAngle.round()}°",
                        onChanged: (value) => _onAngleChangedByUI(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Finalize angle from UI and tell game to move
                      double angleToSet =
                          _sliderAngle; // Slider is source of truth after _onAngleChangedByUI
                      widget.game.setBoatAngleAndStart(angleToSet);
                    },
                    child: const Text("Set Angle & Move Boat"),
                  ),
                ),
              ] else ...[
                // Drag-to-Rotate Mode UI
                ValueListenableBuilder<double>(
                  valueListenable: widget.game.currentAngleNotifier,
                  builder: (context, angle, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      alignment: Alignment.center,
                      child: Text(
                        "Current Angle: ${angle.toStringAsFixed(1)}°\n(Drag on river to aim and release to move)",
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
