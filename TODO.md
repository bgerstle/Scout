# To Do

## Future versions
- [ ] Quick/Nimble integration
- [ ] Argument capture / API for persisting & inspecting mock calls
- [ ] Automatic verification (hook into XCTestObserver to call verify() on tearDown)
- [ ] Automatic disabling of continueAfterFailure
- [ ] Distinguish between functions with different arg labels
- [ ] Better "remaining expectations" failure messages (omit members w/ no expectations)

## v0.0.1
- [x] Documentation
- [x] Stub simple var return values
- [x] Replace assertion failures with XCTest failure reports
- [x] Support "always return"
- [x] Stub expected instance method calls and return values
- [x] Verify expected instance method calls
- [x] Stub side effects (e.g. exception throwing) for methods
- [x] Report mock failures with file & line of call site
- [x] Verify all expectations were called
- [x] More descriptive failure messages
- [x] Swift package support
- [x] macOS support
