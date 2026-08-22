#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static NSString * const HPDefaultPrinterQueue = @"HP_LaserJet_1020";

static NSError *HPError(NSString *message) {
    return [NSError errorWithDomain:@"local.codex.hp1020-manual-duplex"
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"Unknown error / 未知错误"}];
}

@interface HPAppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) NSTextField *titleLabel;
@property(nonatomic, strong) NSTextField *subtitleLabel;
@property(nonatomic, strong) NSTextField *languageLabel;
@property(nonatomic, strong) NSPopUpButton *languagePopup;
@property(nonatomic, strong) NSTextField *bindingLabel;
@property(nonatomic, strong) NSPopUpButton *bindingPopup;
@property(nonatomic, strong) NSTextField *bindingHintLabel;
@property(nonatomic, strong) NSButton *chooseButton;
@property(nonatomic, strong) NSButton *testButton;
@property(nonatomic, strong) NSTextField *noteLabel;
@property(nonatomic, strong) NSTextField *refillTitleLabel;
@property(nonatomic, strong) NSTextField *statusLabel;
@property(nonatomic, strong) NSProgressIndicator *spinner;
@property(nonatomic, strong) NSStackView *refillStack;
@property(nonatomic, strong) NSButton *refillCheckbox;
@property(nonatomic, strong) NSButton *continueSecondButton;
@property(nonatomic, strong) NSButton *cancelDuplexButton;
@property(nonatomic, copy) NSString *pendingBackPath;
@property(nonatomic, copy) NSString *pendingWorkDir;
@property(nonatomic, copy) NSString *pendingSecondTitle;
@property(nonatomic, copy) NSString *printerQueue;
@property(nonatomic, copy) NSString *language;
@property(nonatomic, assign) BOOL busy;
@end

@implementation HPAppDelegate

- (NSString *)L:(NSString *)key {
    static NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
            @"zh": @{
                @"windowTitle": @"HP1020 手动双面打印",
                @"title": @"HP LaserJet 1020 手动双面打印",
                @"subtitle": @"程序会先打印第一面，然后暂停并提醒你重新放纸一次。只有确认纸张已放回后，才会打印第二面。",
                @"language": @"语言：",
                @"binding": @"装订方向：",
                @"longEdge": @"长边装订（像书一样左右翻）",
                @"shortEdge": @"短边装订（像台历一样上下翻）",
                @"longHint": @"长边模式：左右翻页后，两面文字方向一致。",
                @"shortHint": @"短边模式：上下翻页后两面正立；直接比较纸张两面时相差 180° 是正常的。",
                @"choosePDF": @"选择 PDF 双面打印",
                @"runTest": @"运行内置方向测试",
                @"reloadNote": @"翻纸：整叠取出且不要调整页序；已打印面朝下；纸张底边先放入进纸盒。",
                @"refillTitle": @"第一面已完成：请重新放纸一次。未确认前，第二面作业不会创建。",
                @"refillCheck": @"我已按提示重新放好纸张",
                @"printSecond": @"打印第二面",
                @"cancel": @"取消双面打印",
                @"printerReady": @"打印机：HP LaserJet 1020",
                @"choosePanel": @"选择要双面打印的 PDF",
                @"testMissing": @"内置两页测试 PDF 缺失。",
                @"unknownError": @"未知错误",
                @"launchFailed": @"无法启动命令",
                @"queueMissing": @"找不到可用的 HP LaserJet 1020 打印队列。",
                @"queueBusy": @"打印队列中还有其他作业。请先等待队列清空，再开始双面打印。",
                @"qpdfMissing": @"找不到 PDF 页面处理组件 qpdf。",
                @"queueTimeout": @"等待打印机完成作业超时。请检查缺纸、卡纸或 USB 连接。",
                @"pdfUnreadable": @"无法读取 PDF。",
                @"blankMissing": @"内置空白页资源缺失。",
                @"frontDoneFormat": @"第一面（共 %ld 页）已完成；等待重新放纸。",
                @"printingSecond": @"正在打印第二面（偶数页）…",
                @"secondFailed": @"第二面打印未完成。",
                @"duplexDone": @"双面打印完成。",
                @"duplexDoneTitle": @"双面打印完成",
                @"duplexDoneInfo": @"两面均已发送并完成打印。",
                @"ok": @"好",
                @"canceled": @"已取消第二面打印。",
                @"preparingFormat": @"正在准备 %@…",
                @"printingFront": @"正在打印第一面（奇数页）…",
                @"firstSideTitle": @" - 第一面",
                @"secondSideTitle": @" - 第二面",
                @"printFailed": @"打印未完成。",
                @"singleDone": @"单页打印完成。",
                @"singleDoneTitle": @"打印完成",
                @"singleDoneInfo": @"文档只有一页，已经打印完成。",
                @"errorTitle": @"无法完成双面打印"
            },
            @"en": @{
                @"windowTitle": @"HP1020 Manual Duplex",
                @"title": @"HP LaserJet 1020 Manual Duplex",
                @"subtitle": @"The app prints the first side, pauses, and asks you to reload the paper once. The second side is not submitted until you confirm the reload.",
                @"language": @"Language:",
                @"binding": @"Binding:",
                @"longEdge": @"Long edge (flip like a book)",
                @"shortEdge": @"Short edge (flip like a calendar)",
                @"longHint": @"Long edge: both sides are upright after flipping left to right.",
                @"shortHint": @"Short edge: both sides are upright after flipping top to bottom; a 180° difference when directly comparing the two faces is normal.",
                @"choosePDF": @"Choose PDF and Print",
                @"runTest": @"Run Orientation Test",
                @"reloadNote": @"Reload: keep the stack order; printed side down; feed the bottom edge into the tray first.",
                @"refillTitle": @"The first side is complete. Reload the paper once. No second-side job is created until you confirm.",
                @"refillCheck": @"I reloaded the paper as shown",
                @"printSecond": @"Print Second Side",
                @"cancel": @"Cancel Duplex Job",
                @"printerReady": @"Printer: HP LaserJet 1020",
                @"choosePanel": @"Choose a PDF for manual duplex printing",
                @"testMissing": @"The built-in two-page test PDF is missing.",
                @"unknownError": @"Unknown error",
                @"launchFailed": @"Unable to launch the command",
                @"queueMissing": @"The HP LaserJet 1020 print queue is not available.",
                @"queueBusy": @"The print queue still contains another job. Wait for it to clear before starting manual duplex printing.",
                @"qpdfMissing": @"The qpdf PDF page-processing component was not found.",
                @"queueTimeout": @"Timed out while waiting for the printer. Check for missing paper, a paper jam, or the USB connection.",
                @"pdfUnreadable": @"Unable to read the PDF.",
                @"blankMissing": @"The built-in blank-page resource is missing.",
                @"frontDoneFormat": @"First side complete (%ld pages total); waiting for paper reload.",
                @"printingSecond": @"Printing the second side (even pages)…",
                @"secondFailed": @"Second-side printing did not complete.",
                @"duplexDone": @"Manual duplex printing complete.",
                @"duplexDoneTitle": @"Manual Duplex Complete",
                @"duplexDoneInfo": @"Both sides were submitted and completed.",
                @"ok": @"OK",
                @"canceled": @"Second-side printing canceled.",
                @"preparingFormat": @"Preparing %@…",
                @"printingFront": @"Printing the first side (odd pages)…",
                @"firstSideTitle": @" - First Side",
                @"secondSideTitle": @" - Second Side",
                @"printFailed": @"Printing did not complete.",
                @"singleDone": @"Single-page printing complete.",
                @"singleDoneTitle": @"Printing Complete",
                @"singleDoneInfo": @"The document contains one page and has finished printing.",
                @"errorTitle": @"Unable to Complete Manual Duplex Printing"
            }
        };
    });
    NSString *language = self.language ?: @"en";
    return strings[language][key] ?: strings[@"en"][key] ?: key;
}

- (void)detectInitialLanguage {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:@"HP1020Language"];
    if ([saved isEqualToString:@"zh"] || [saved isEqualToString:@"en"]) {
        self.language = saved;
        return;
    }
    NSString *preferred = NSLocale.preferredLanguages.firstObject.lowercaseString ?: @"en";
    self.language = [preferred hasPrefix:@"zh"] ? @"zh" : @"en";
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self detectInitialLanguage];
    [self buildWindow];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    if (self.pendingWorkDir.length > 0) {
        [NSFileManager.defaultManager removeItemAtPath:self.pendingWorkDir error:nil];
    }
}

- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames {
    NSString *path = filenames.firstObject;
    if (path.length > 0 && [path.pathExtension.lowercaseString isEqualToString:@"pdf"]) {
        [self startPrintingURL:[NSURL fileURLWithPath:path]];
        [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
    } else {
        [sender replyToOpenOrPrint:NSApplicationDelegateReplyFailure];
    }
}

- (NSTextField *)label:(NSString *)text size:(CGFloat)size weight:(NSFontWeight)weight {
    NSTextField *label = [NSTextField labelWithString:text];
    label.font = [NSFont systemFontOfSize:size weight:weight];
    label.alignment = NSTextAlignmentCenter;
    return label;
}

- (void)buildWindow {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 680, 470)
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.releasedWhenClosed = NO;
    [self.window center];

    self.titleLabel = [self label:@"" size:22 weight:NSFontWeightSemibold];
    self.subtitleLabel = [NSTextField wrappingLabelWithString:@""];
    self.subtitleLabel.font = [NSFont systemFontOfSize:14];
    self.subtitleLabel.textColor = NSColor.secondaryLabelColor;
    self.subtitleLabel.alignment = NSTextAlignmentCenter;
    self.subtitleLabel.maximumNumberOfLines = 3;

    self.languageLabel = [NSTextField labelWithString:@""];
    self.languagePopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    [self.languagePopup addItemsWithTitles:@[@"中文", @"English"]];
    [self.languagePopup selectItemAtIndex:[self.language isEqualToString:@"zh"] ? 0 : 1];
    self.languagePopup.target = self;
    self.languagePopup.action = @selector(languageChanged:);
    NSStackView *languageRow = [NSStackView stackViewWithViews:@[self.languageLabel, self.languagePopup]];
    languageRow.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    languageRow.spacing = 8;
    languageRow.alignment = NSLayoutAttributeCenterY;

    self.bindingLabel = [NSTextField labelWithString:@""];
    self.bindingPopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.bindingPopup.target = self;
    self.bindingPopup.action = @selector(bindingChanged:);
    NSStackView *bindingRow = [NSStackView stackViewWithViews:@[self.bindingLabel, self.bindingPopup]];
    bindingRow.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    bindingRow.spacing = 8;
    bindingRow.alignment = NSLayoutAttributeCenterY;

    NSStackView *settingsRow = [NSStackView stackViewWithViews:@[languageRow, bindingRow]];
    settingsRow.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    settingsRow.spacing = 24;
    settingsRow.alignment = NSLayoutAttributeCenterY;

    self.bindingHintLabel = [NSTextField wrappingLabelWithString:@""];
    self.bindingHintLabel.font = [NSFont systemFontOfSize:12.5 weight:NSFontWeightMedium];
    self.bindingHintLabel.textColor = NSColor.systemBlueColor;
    self.bindingHintLabel.alignment = NSTextAlignmentCenter;
    self.bindingHintLabel.maximumNumberOfLines = 2;

    self.chooseButton = [NSButton buttonWithTitle:@"" target:self action:@selector(choosePDF:)];
    self.chooseButton.bezelStyle = NSBezelStyleRounded;
    self.chooseButton.controlSize = NSControlSizeLarge;
    self.chooseButton.keyEquivalent = @"\r";

    self.testButton = [NSButton buttonWithTitle:@"" target:self action:@selector(runBuiltInTest:)];
    self.testButton.bezelStyle = NSBezelStyleRounded;
    self.testButton.controlSize = NSControlSizeLarge;

    NSStackView *buttonRow = [NSStackView stackViewWithViews:@[self.chooseButton, self.testButton]];
    buttonRow.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    buttonRow.spacing = 12;

    self.noteLabel = [NSTextField wrappingLabelWithString:@""];
    self.noteLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    self.noteLabel.textColor = NSColor.labelColor;
    self.noteLabel.alignment = NSTextAlignmentCenter;
    self.noteLabel.maximumNumberOfLines = 3;

    self.refillTitleLabel = [NSTextField wrappingLabelWithString:@""];
    self.refillTitleLabel.font = [NSFont systemFontOfSize:14 weight:NSFontWeightBold];
    self.refillTitleLabel.textColor = NSColor.systemOrangeColor;
    self.refillTitleLabel.alignment = NSTextAlignmentCenter;
    self.refillTitleLabel.maximumNumberOfLines = 3;

    self.refillCheckbox = [NSButton checkboxWithTitle:@"" target:self action:@selector(refillCheckboxChanged:)];
    self.refillCheckbox.font = [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold];
    self.continueSecondButton = [NSButton buttonWithTitle:@"" target:self action:@selector(continueSecondSide:)];
    self.continueSecondButton.bezelStyle = NSBezelStyleRounded;
    self.continueSecondButton.enabled = NO;
    self.cancelDuplexButton = [NSButton buttonWithTitle:@"" target:self action:@selector(cancelPendingDuplex:)];
    self.cancelDuplexButton.bezelStyle = NSBezelStyleRounded;
    NSStackView *refillButtons = [NSStackView stackViewWithViews:@[self.continueSecondButton, self.cancelDuplexButton]];
    refillButtons.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    refillButtons.spacing = 10;
    self.refillStack = [NSStackView stackViewWithViews:@[self.refillTitleLabel, self.refillCheckbox, refillButtons]];
    self.refillStack.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.refillStack.alignment = NSLayoutAttributeCenterX;
    self.refillStack.spacing = 10;
    self.refillStack.hidden = YES;

    self.spinner = [[NSProgressIndicator alloc] init];
    self.spinner.style = NSProgressIndicatorStyleSpinning;
    self.spinner.controlSize = NSControlSizeSmall;
    self.spinner.displayedWhenStopped = NO;
    self.statusLabel = [NSTextField labelWithString:@""];
    self.statusLabel.textColor = NSColor.secondaryLabelColor;
    NSStackView *statusRow = [NSStackView stackViewWithViews:@[self.spinner, self.statusLabel]];
    statusRow.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    statusRow.spacing = 8;
    statusRow.alignment = NSLayoutAttributeCenterY;

    NSStackView *stack = [NSStackView stackViewWithViews:@[self.titleLabel, self.subtitleLabel, settingsRow, self.bindingHintLabel, buttonRow, self.noteLabel, self.refillStack, statusRow]];
    stack.orientation = NSUserInterfaceLayoutOrientationVertical;
    stack.alignment = NSLayoutAttributeCenterX;
    stack.spacing = 18;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.window.contentView addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:self.window.contentView.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:self.window.contentView.centerYAnchor],
        [self.subtitleLabel.widthAnchor constraintEqualToConstant:600],
        [self.bindingHintLabel.widthAnchor constraintEqualToConstant:610],
        [self.noteLabel.widthAnchor constraintEqualToConstant:610],
        [self.refillTitleLabel.widthAnchor constraintEqualToConstant:610],
        [self.chooseButton.widthAnchor constraintEqualToConstant:250],
        [self.testButton.widthAnchor constraintEqualToConstant:230],
        [self.chooseButton.heightAnchor constraintEqualToConstant:40],
        [self.testButton.heightAnchor constraintEqualToConstant:40]
    ]];
    [self updateLocalizedStrings];
}

- (void)languageChanged:(id)sender {
    self.language = self.languagePopup.indexOfSelectedItem == 0 ? @"zh" : @"en";
    [NSUserDefaults.standardUserDefaults setObject:self.language forKey:@"HP1020Language"];
    [self updateLocalizedStrings];
}

- (void)bindingChanged:(id)sender {
    [self updateBindingHint];
}

- (void)updateBindingHint {
    self.bindingHintLabel.stringValue = [self L:(self.bindingPopup.indexOfSelectedItem == 1 ? @"shortHint" : @"longHint")];
}

- (void)updateLocalizedStrings {
    NSInteger bindingIndex = self.bindingPopup.indexOfSelectedItem;
    self.window.title = [self L:@"windowTitle"];
    self.titleLabel.stringValue = [self L:@"title"];
    self.subtitleLabel.stringValue = [self L:@"subtitle"];
    self.languageLabel.stringValue = [self L:@"language"];
    self.bindingLabel.stringValue = [self L:@"binding"];
    [self.bindingPopup removeAllItems];
    [self.bindingPopup addItemsWithTitles:@[[self L:@"longEdge"], [self L:@"shortEdge"]]];
    [self.bindingPopup selectItemAtIndex:MAX(0, bindingIndex)];
    [self updateBindingHint];
    self.chooseButton.title = [self L:@"choosePDF"];
    self.testButton.title = [self L:@"runTest"];
    self.noteLabel.stringValue = [self L:@"reloadNote"];
    self.refillTitleLabel.stringValue = [self L:@"refillTitle"];
    self.refillCheckbox.title = [self L:@"refillCheck"];
    self.continueSecondButton.title = [self L:@"printSecond"];
    self.cancelDuplexButton.title = [self L:@"cancel"];
    if (!self.busy && self.refillStack.hidden) self.statusLabel.stringValue = [self L:@"printerReady"];
}

- (void)setBusy:(BOOL)busy status:(NSString *)status {
    self.busy = busy;
    self.chooseButton.enabled = !busy;
    self.testButton.enabled = !busy;
    self.bindingPopup.enabled = !busy;
    self.languagePopup.enabled = !busy;
    self.statusLabel.stringValue = status;
    busy ? [self.spinner startAnimation:nil] : [self.spinner stopAnimation:nil];
}

- (void)choosePDF:(id)sender {
    if (self.busy) return;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.title = [self L:@"choosePanel"];
    panel.allowedContentTypes = @[UTTypePDF];
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = NO;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK && panel.URL) [self startPrintingURL:panel.URL];
    }];
}

- (void)runBuiltInTest:(id)sender {
    if (self.busy) return;
    NSString *path = [NSBundle.mainBundle pathForResource:@"two-page-test" ofType:@"pdf"];
    if (!path) {
        [self showError:HPError([self L:@"testMissing"])];
        return;
    }
    [self startPrintingURL:[NSURL fileURLWithPath:path]];
}

- (NSDictionary *)runTask:(NSString *)launchPath arguments:(NSArray<NSString *> *)arguments {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    task.executableURL = [NSURL fileURLWithPath:launchPath];
    task.arguments = arguments;
    task.standardOutput = pipe;
    task.standardError = pipe;
    NSError *error = nil;
    if (![task launchAndReturnError:&error]) {
        return @{ @"status": @(-1), @"output": error.localizedDescription ?: [self L:@"launchFailed"] };
    }
    [task waitUntilExit];
    NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
    return @{ @"status": @(task.terminationStatus), @"output": output };
}

- (NSString *)qpdfPath {
    for (NSString *path in @[@"/opt/homebrew/bin/qpdf", @"/usr/local/bin/qpdf"]) {
        if ([NSFileManager.defaultManager isExecutableFileAtPath:path]) return path;
    }
    return nil;
}

- (BOOL)verifyPrinter:(NSError **)error {
    NSString *queue = self.printerQueue ?: HPDefaultPrinterQueue;
    NSDictionary *printer = [self runTask:@"/usr/bin/lpstat" arguments:@[@"-p", queue, @"-l"]];
    if ([printer[@"status"] intValue] != 0) {
        NSDictionary *available = [self runTask:@"/usr/bin/lpstat" arguments:@[@"-a"]];
        for (NSString *line in [available[@"output"] componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet]) {
            NSString *candidate = [line componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet].firstObject;
            if ([[candidate lowercaseString] containsString:@"1020"]) {
                queue = candidate;
                printer = [self runTask:@"/usr/bin/lpstat" arguments:@[@"-p", queue, @"-l"]];
                if ([printer[@"status"] intValue] == 0) break;
            }
        }
    }
    if ([printer[@"status"] intValue] != 0) {
        if (error) *error = HPError([NSString stringWithFormat:@"%@\n\n%@", [self L:@"queueMissing"], printer[@"output"]]);
        return NO;
    }
    self.printerQueue = queue;
    NSDictionary *pending = [self runTask:@"/usr/bin/lpstat" arguments:@[@"-o", queue]];
    NSString *pendingText = [pending[@"output"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (pendingText.length > 0) {
        if (error) *error = HPError([self L:@"queueBusy"]);
        return NO;
    }
    if (![self qpdfPath]) {
        if (error) *error = HPError([self L:@"qpdfMissing"]);
        return NO;
    }
    return YES;
}

- (BOOL)waitUntilQueueIsEmpty:(NSError **)error {
    NSString *queue = self.printerQueue ?: HPDefaultPrinterQueue;
    for (NSInteger attempt = 0; attempt < 600; attempt++) {
        [NSThread sleepForTimeInterval:1.0];
        NSDictionary *pending = [self runTask:@"/usr/bin/lpstat" arguments:@[@"-o", queue]];
        NSString *text = [pending[@"output"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if ([pending[@"status"] intValue] == 0 && text.length == 0) return YES;
        NSDictionary *state = [self runTask:@"/usr/bin/lpstat" arguments:@[@"-p", queue, @"-l"]];
        NSString *normalized = [state[@"output"] lowercaseString];
        if ([normalized containsString:@"disabled"] || [normalized containsString:@"stopped"] || [normalized containsString:@"已停用"]) {
            if (error) *error = HPError(state[@"output"]);
            return NO;
        }
    }
    if (error) *error = HPError([self L:@"queueTimeout"]);
    return NO;
}

- (BOOL)submitPDF:(NSString *)path title:(NSString *)title error:(NSError **)error {
    NSString *queue = self.printerQueue ?: HPDefaultPrinterQueue;
    NSDictionary *result = [self runTask:@"/usr/bin/lp" arguments:@[
        @"-d", queue, @"-t", title, @"-o", @"media=A4", @"-o", @"fit-to-page", @"--", path
    ]];
    if ([result[@"status"] intValue] != 0) {
        if (error) *error = HPError(result[@"output"]);
        return NO;
    }
    return [self waitUntilQueueIsEmpty:error];
}

- (BOOL)prepareDocuments:(NSURL *)sourceURL
                workDir:(NSString *)workDir
              shortEdge:(BOOL)shortEdge
               pageCount:(NSInteger *)pageCount
                  front:(NSString **)frontPath
                   back:(NSString **)backPath
                  error:(NSError **)error {
    NSString *qpdf = [self qpdfPath];
    NSDictionary *countResult = [self runTask:qpdf arguments:@[@"--show-npages", sourceURL.path]];
    NSInteger count = [[countResult[@"output"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] integerValue];
    if ([countResult[@"status"] intValue] != 0 || count < 1) {
        if (error) *error = HPError([NSString stringWithFormat:@"%@\n\n%@", [self L:@"pdfUnreadable"], countResult[@"output"]]);
        return NO;
    }

    NSMutableArray<NSString *> *frontPageNumbers = [NSMutableArray array];
    for (NSInteger page = 1; page <= count; page += 2) {
        [frontPageNumbers addObject:[NSString stringWithFormat:@"%ld", (long)page]];
    }
    NSString *frontRange = [frontPageNumbers componentsJoinedByString:@","];
    NSString *front = [workDir stringByAppendingPathComponent:@"front.pdf"];
    NSDictionary *frontResult = [self runTask:qpdf arguments:@[@"--empty", @"--pages", sourceURL.path, frontRange, @"--", front]];
    if ([frontResult[@"status"] intValue] != 0) {
        if (error) *error = HPError(frontResult[@"output"]);
        return NO;
    }

    NSString *back = nil;
    if (count > 1) {
        NSString *rawBack = [workDir stringByAppendingPathComponent:@"back-raw.pdf"];
        NSMutableArray<NSString *> *args = [NSMutableArray arrayWithArray:@[@"--empty", @"--pages"]];
        if (count % 2 == 1) {
            NSString *blank = [NSBundle.mainBundle pathForResource:@"blank-a4" ofType:@"pdf"];
            if (!blank) {
                if (error) *error = HPError([self L:@"blankMissing"]);
                return NO;
            }
            [args addObjectsFromArray:@[blank, @"1"]];
        }
        NSMutableArray<NSString *> *backPageNumbers = [NSMutableArray array];
        NSInteger lastEvenPage = count % 2 == 0 ? count : count - 1;
        for (NSInteger page = lastEvenPage; page >= 2; page -= 2) {
            [backPageNumbers addObject:[NSString stringWithFormat:@"%ld", (long)page]];
        }
        NSString *backRange = [backPageNumbers componentsJoinedByString:@","];
        [args addObjectsFromArray:@[sourceURL.path, backRange, @"--", rawBack]];
        NSDictionary *backResult = [self runTask:qpdf arguments:args];
        if ([backResult[@"status"] intValue] != 0) {
            if (error) *error = HPError(backResult[@"output"]);
            return NO;
        }

        back = [workDir stringByAppendingPathComponent:@"back.pdf"];
        // HP 1020 官方翻纸方法是“打印面朝下、底边先入”。
        // 这种重新进纸方式要求长边装订的第二面预先旋转 180°；短边装订不旋转。
        if (!shortEdge) {
            NSDictionary *rotateResult = [self runTask:qpdf arguments:@[rawBack, @"--rotate=+180:1-z", back]];
            if ([rotateResult[@"status"] intValue] != 0) {
                if (error) *error = HPError(rotateResult[@"output"]);
                return NO;
            }
        } else {
            NSError *copyError = nil;
            if (![NSFileManager.defaultManager copyItemAtPath:rawBack toPath:back error:&copyError]) {
                if (error) *error = copyError;
                return NO;
            }
        }
    }

    if (pageCount) *pageCount = count;
    if (frontPath) *frontPath = front;
    if (backPath) *backPath = back;
    return YES;
}

- (void)refillCheckboxChanged:(NSButton *)sender {
    self.continueSecondButton.enabled = sender.state == NSControlStateValueOn;
}

- (void)showRefillStepForPageCount:(NSInteger)pageCount {
    self.refillCheckbox.state = NSControlStateValueOff;
    self.continueSecondButton.enabled = NO;
    self.refillStack.hidden = NO;
    [self.spinner stopAnimation:nil];
    self.statusLabel.stringValue = [NSString stringWithFormat:[self L:@"frontDoneFormat"], (long)pageCount];
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp requestUserAttention:NSCriticalRequest];
}

- (void)hideRefillStep {
    self.refillStack.hidden = YES;
    self.refillCheckbox.state = NSControlStateValueOff;
    self.continueSecondButton.enabled = NO;
}

- (void)clearPendingDuplexFiles {
    if (self.pendingWorkDir.length > 0) {
        [NSFileManager.defaultManager removeItemAtPath:self.pendingWorkDir error:nil];
    }
    self.pendingBackPath = nil;
    self.pendingWorkDir = nil;
    self.pendingSecondTitle = nil;
}

- (void)continueSecondSide:(id)sender {
    if (self.refillCheckbox.state != NSControlStateValueOn || self.pendingBackPath.length == 0) return;
    NSString *backPath = self.pendingBackPath;
    NSString *workDir = self.pendingWorkDir;
    NSString *title = self.pendingSecondTitle;
    self.refillCheckbox.enabled = NO;
    self.continueSecondButton.enabled = NO;
    self.cancelDuplexButton.enabled = NO;
    [self.spinner startAnimation:nil];
    self.statusLabel.stringValue = [self L:@"printingSecond"];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSError *error = nil;
        [self submitPDF:backPath title:title error:&error];
        [NSFileManager.defaultManager removeItemAtPath:workDir error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pendingBackPath = nil;
            self.pendingWorkDir = nil;
            self.pendingSecondTitle = nil;
            self.refillCheckbox.enabled = YES;
            self.cancelDuplexButton.enabled = YES;
            [self hideRefillStep];
            if (error) {
                [self setBusy:NO status:[self L:@"secondFailed"]];
                [self showError:error];
            } else {
                [self setBusy:NO status:[self L:@"duplexDone"]];
                NSAlert *done = [[NSAlert alloc] init];
                done.messageText = [self L:@"duplexDoneTitle"];
                done.informativeText = [self L:@"duplexDoneInfo"];
                [done addButtonWithTitle:[self L:@"ok"]];
                [done beginSheetModalForWindow:self.window completionHandler:nil];
            }
        });
    });
}

- (void)cancelPendingDuplex:(id)sender {
    [self clearPendingDuplexFiles];
    [self hideRefillStep];
    [self setBusy:NO status:[self L:@"canceled"]];
}

- (void)startPrintingURL:(NSURL *)url {
    if (self.busy || !url) return;
    BOOL shortEdge = self.bindingPopup.indexOfSelectedItem == 1;
    [self setBusy:YES status:[NSString stringWithFormat:[self L:@"preparingFormat"], url.lastPathComponent]];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        @autoreleasepool {
            NSError *error = nil;
            NSString *workDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"HP1020Duplex-%@", NSUUID.UUID.UUIDString]];
            [NSFileManager.defaultManager createDirectoryAtPath:workDir withIntermediateDirectories:YES attributes:nil error:&error];

            NSInteger pageCount = 0;
            NSString *front = nil;
            NSString *back = nil;
            if (!error && [self verifyPrinter:&error] &&
                [self prepareDocuments:url workDir:workDir shortEdge:shortEdge pageCount:&pageCount front:&front back:&back error:&error]) {
                dispatch_async(dispatch_get_main_queue(), ^{ self.statusLabel.stringValue = [self L:@"printingFront"]; });
                NSString *baseName = url.URLByDeletingPathExtension.lastPathComponent;
                if ([self submitPDF:front title:[baseName stringByAppendingString:[self L:@"firstSideTitle"]] error:&error]) {
                    if (back) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.pendingBackPath = back;
                            self.pendingWorkDir = workDir;
                            self.pendingSecondTitle = [baseName stringByAppendingString:[self L:@"secondSideTitle"]];
                            [self showRefillStepForPageCount:pageCount];
                        });
                        return;
                    }
                }
            }

            [NSFileManager.defaultManager removeItemAtPath:workDir error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [self setBusy:NO status:[self L:@"printFailed"]];
                    [self showError:error];
                } else {
                    [self setBusy:NO status:[self L:@"singleDone"]];
                    NSAlert *done = [[NSAlert alloc] init];
                    done.messageText = [self L:@"singleDoneTitle"];
                    done.informativeText = [self L:@"singleDoneInfo"];
                    [done addButtonWithTitle:[self L:@"ok"]];
                    [done beginSheetModalForWindow:self.window completionHandler:nil];
                }
            });
        }
    });
}

- (void)showError:(NSError *)error {
    [NSApp activateIgnoringOtherApps:YES];
    NSAlert *alert = [NSAlert alertWithError:error];
    alert.messageText = [self L:@"errorTitle"];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = NSApplication.sharedApplication;
        HPAppDelegate *delegate = [[HPAppDelegate alloc] init];
        application.delegate = delegate;
        [application setActivationPolicy:NSApplicationActivationPolicyRegular];
        [application run];
    }
    return 0;
}
