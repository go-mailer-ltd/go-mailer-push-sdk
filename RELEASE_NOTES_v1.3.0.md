# Go Mailer SDK 1.3.0

Release Date: 2025-10-02

## Highlights
- Cross-platform parity: Flutter, Android, iOS, React Native all aligned at 1.3.0
- Persistent event queue (SharedPreferences/UserDefaults) with capacity cap (100)
- Structured event taxonomy (initialized, stream_ready, registered, event_queued, event_tracked, event_failed, event_dropped, notification_clicked)
- Exponential backoff with jitter for network reliability
- Privacy: API key masking in logs, email masking + maskedEmail field on events
- Diagnostic API: `getSdkInfo` for runtime verification & debugging
- Added CI workflows (tests + publish automation scaffold)
- JitPack distribution path for Android (no Maven Central dependency yet)

## Breaking Changes
- None (semver minor bump skipping 1.2.0 intentionally to unify multi-platform versioning).

## New Features
- getSdkInfo Dart/Android/iOS/React Native
- Event persistence & retry/backoff
- Email masking logic with `maskedEmail` field in payloads

## Improvements
- Consistent version constant access across platforms
- Queue capacity management with `event_dropped` signal
- Documentation updates & badges
- Automated pre-flight script (`scripts/release.sh`)

## Internal / Tooling
- Added `.pubignore`, CI test workflow, and publish workflow skeleton
- Cleaned repository of legacy example apps & artifacts

## Migration Notes
- Update Flutter dependency to `go_mailer_push_sdk: ^1.3.0`
- Android consumers now use JitPack coordinate `com.github.go-mailer-ltd:go-mailer-push-sdk:1.3.0`
- React Native consumers install `go-mailer-push-sdk@1.3.0`
- Native iOS integration (non-Flutter) can adopt `GoMailerPushSDK` pod once trunk pushed.

## Verification Checklist
- [x] Flutter tests green
- [x] React Native TypeScript build succeeds
- [x] Android `assembleRelease` successful
- [x] Version alignment script passes

## Next (Roadmap Ideas)
- Optional configurable queue size
- Advanced privacy redaction policies
- Automatic flush scheduling & adaptive batching
- Maven Central publication with signed artifacts
- Expanded test coverage (integration + stress tests)
