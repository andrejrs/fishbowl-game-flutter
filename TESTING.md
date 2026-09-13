# Testing Guide

This project has a full Flutter widget/unit test suite under [`test/`](test/),
which runs in the Flutter widget test harness (fast, no device needed), plus
a Flutter integration test under [`integration_test/`](integration_test/) that
drives the real, compiled app end-to-end on a real device or emulator.

## What's covered

| File | Covers |
|---|---|
| `test/models_test.dart` | `Player`, `Team`, `GameWord`, `GameState`, `FishbowlRound` (`lib/models.dart`) |
| `test/widgets/team_row_test.dart` | `TeamRow` avatar/name rendering |
| `test/screens/components/circular_countdown_test.dart` | Countdown text + green/yellow/red color thresholds |
| `test/screens/components/podium_screen_test.dart` | Podium ranking, top-3 vs. overflow list, edge cases |
| `test/screens/setup_screen_test.dart` | Defaults, validation, name add/remove/duplicate rules, `SharedPreferences` persistence, navigation |
| `test/screens/team_assignment_screen_test.dart` | Random team assignment (fairness, completeness), navigation |
| `test/screens/word_entry_screen_test.dart` | Per-player word entry, duplicate detection (same + cross player), navigation |
| `test/screens/game_screen_test.dart` | Turn timer, scoring, round/team transitions, timeout handling, full 3-round game |
| `test/screens/end_of_round_screen_test.dart` | Score bar rendering, "Start Next Round" callback |
| `test/screens/results_screen_test.dart` | Final score display, restart navigation |
| `test/widget_test.dart` | App-level smoke test: routes, initial screen, setup → teams flow |
| `integration_test/app_test.dart` | Full end-to-end game on a real device: Setup (add players) → Team Assignment → Word Entry → all 3 rounds (Taboo, Charades, One Word) → Results, asserting the final per-team scores |

`test/test_helpers.dart` holds shared test utilities (see [Gotchas](#gotchas-this-suite-works-around) below).

## Running the tests

Run everything:

```bash
flutter test
```

Run a single file:

```bash
flutter test test/screens/game_screen_test.dart
```

Run a single test by name (substring match):

```bash
flutter test test/screens/setup_screen_test.dart --plain-name "does not add duplicate"
```

Run with more verbose output (useful when a test hangs or you need to see
`debugPrint`/`print` output):

```bash
flutter test --reporter expanded
```

## Integration tests

Unlike `test/`, which pumps widgets in a simulated harness, `integration_test/app_test.dart`
launches the actual compiled app (`app.main()`) and drives it via real taps and
text entry, on a real device/emulator (USB-connected phone, or a desktop/web
target once that platform's build toolchain is set up). It plays through the
full game once — 2 teams, 2 players, 4 words — guessing every word each round
so rounds resolve immediately instead of waiting out the real turn timer, then
asserts the final scores (Team 1: 8, Team 2: 4) on the Results screen.

There are two ways to run it, and they behave differently:

### `flutter test` — fast, headless

```bash
flutter devices                                       # find the device id
flutter test integration_test/app_test.dart -d <id>
```

This is the one to use day-to-day and in CI: it installs and runs the real
app, but renders off-screen for speed, so the device's screen won't show
anything changing (see [Gotchas](#gotchas-this-suite-works-around) below). The
whole run takes a few seconds.

### `flutter drive` — slow, visible

To actually watch the test drive the app on-screen (e.g. to sanity-check it
by eye, like watching a Selenium run step through a browser), use the older
`flutter drive` command instead, which requires the driver entrypoint at
[`test_driver/integration_test.dart`](test_driver/integration_test.dart):

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d <id>
```

By default this still runs at full speed (too fast to follow). Add
`--dart-define=STEP_DELAY_MS=<ms>` to insert a real pause after every step:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d <id> \
  --dart-define=STEP_DELAY_MS=800
```

`flutter drive` also rebuilds/reinstalls the APK each run (adds ~15-20s) and
closes the app once the test finishes.

## Code coverage

### Generate the raw coverage data

```bash
flutter test --coverage
```

This produces `coverage/lcov.info` (LCOV format) in the project root. It's
regenerated fresh each run — no need to delete it first.

### Get a percentage

**Option A — install `lcov`'s `genhtml`/`lcov` tools (recommended, gives an
HTML report you can browse file-by-file):**

```bash
sudo dnf install lcov          # Fedora (this machine)
# sudo apt install lcov        # Debian/Ubuntu
# brew install lcov            # macOS
```

Then:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
xdg-open coverage/html/index.html   # or just open it in a browser
```

`genhtml`'s own console output also prints a summary like:

```
lines......: 94.0% (536 of 570 lines)
```

Or get just the summary without building the HTML report:

```bash
lcov --summary coverage/lcov.info
```

**Option B — no extra tools, one-liner from `lcov.info` directly:**

```bash
awk -F: '/^DA:/{split($2,a,","); total++; if (a[2]+0>0) covered++} \
  END{printf "Lines: %d/%d (%.1f%%)\n", covered, total, (covered/total)*100}' \
  coverage/lcov.info
```

This counts `DA:<line>,<hit-count>` records in the LCOV file: a line is
"covered" if its hit count is `> 0`. It gives the same overall line-coverage
percentage as `lcov --summary`, just without the per-file breakdown.

**Option C — VS Code:** install the "Coverage Gutters" extension, run
`flutter test --coverage`, then use its "Watch" command — it reads
`coverage/lcov.info` and highlights covered/uncovered lines directly in the
editor gutter.

### Excluding files from coverage

If you ever need to exclude generated or trivial files, add a
`coverage_ignore` comment or filter `lcov.info` with `lcov --remove` before
computing the summary, e.g.:

```bash
lcov --remove coverage/lcov.info 'lib/main.dart' -o coverage/lcov.filtered.info
lcov --summary coverage/lcov.filtered.info
```

This repo doesn't currently exclude anything — the numbers above are for all
of `lib/`.

## Gotchas this suite works around

These are real Flutter-testing pitfalls that caused failures while writing
this suite (see `test/test_helpers.dart` for the fixes):

1. **`find.byType` doesn't match subclasses.** `ElevatedButton.icon(...)`
   returns a private subclass, so `find.widgetWithText(ElevatedButton, 'X')`
   silently finds nothing for icon buttons. Use the `elevatedButtonWithText` /
   `elevatedButtonWithIcon` helpers in `test_helpers.dart`, which use
   `find.bySubtype<ElevatedButton>()` instead.

2. **`ListView` culls off-screen children from hit-testing.** As tests add
   more players/words, list items can scroll out of the default (~800×600)
   test viewport and become invisible to `find.byType`/`find.text` (which
   default to `skipOffstage: true`). `useTallTestViewport(tester)` enlarges
   the test surface so this doesn't happen.

3. **`pumpWidget` reuses the existing `Navigator`'s route stack.** Pumping a
   second, structurally-similar widget tree (e.g. to simulate "relaunching"
   `SetupScreen` after a Continue → back-navigation) does **not** reset
   `initialRoute` — the same `Navigator` state is reused. Pump an unrelated
   placeholder widget (e.g. `SizedBox.shrink()`) in between to force a real
   teardown/rebuild.

4. **Timers must be flushed before a test ends.** `Future.delayed(...)` and
   `Timer.periodic(...)` calls in the app (word/player focus refocus,
   `GameScreen`'s countdown and turn-end delay) leave a "pending timer" test
   failure if the test finishes before they fire or are cancelled. Tests
   `pump()` with an explicit `Duration` long enough to flush these, or drive
   the UI to a state where the app code cancels the timer itself.

These apply to `integration_test/app_test.dart` too, plus two that are
specific to running on a real, live device:

5. **`useTallTestViewport` breaks rendering on a real device.** It's built
   for the offline `test/` suite, where the "device" is a virtual, resizable
   test window. `integration_test/app_test.dart` deliberately does **not**
   use it: overriding the window size against a real device's actual
   physical display silently breaks frame rendering entirely — the widget
   tree still responds to taps/text input under the hood, but nothing new
   ever gets painted, leaving the screen stuck on `flutter_test`'s internal
   "Test starting..." placeholder for the whole run. (This suite's player/word
   lists are small enough that culling was never a risk anyway.)

6. **`flutter test integration_test/...` doesn't render visibly on the
   device**, even without the above bug — it deliberately runs the app
   off-screen for speed. If you want to see it happen, use `flutter drive`
   instead (see [Integration tests](#integration-tests) above); even then,
   without `--dart-define=STEP_DELAY_MS=<ms>` the whole run completes in a
   few seconds, too fast to visually follow.

## Adding new tests

- Screen tests that need `ModalRoute.of(context)!.settings.arguments` use the
  `pumpScreenWithArgs(...)` helper in `test/test_helpers.dart` — it fakes a
  named-route push with the given arguments, and can register placeholder
  routes for screens the widget under test navigates to (so you don't have to
  pull in the entire downstream screen just to test navigation).
- Prefer asserting on behavior (what's on screen, what got passed to
  `Navigator`) over reaching into private state.
- If a widget under test uses `SharedPreferences`, call
  `SharedPreferences.setMockInitialValues({})` in `setUp()`.
