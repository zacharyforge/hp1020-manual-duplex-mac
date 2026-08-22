# Changelog / 更新记录

## 4

- Added all-pages and contiguous page-range printing with correct duplex pairing. / 新增全部页和连续页码范围打印，并正确配对双面页。
- Choosing or opening a PDF now only selects it; printing requires a separate Start Printing click. / 选择或打开 PDF 后只会选中文件，必须另外点击“开始打印”。
- Moved the language selector to the upper-right corner and changed its label to “语言 / Language”. / 将语言选项移动到右上角并统一标记为“语言 / Language”。
- Removed success pop-ups after printing; completion remains visible in the status line. / 取消打印成功弹窗，完成状态仍显示在状态栏。
- Added a simple app icon made from two overlapping rectangles. / 新增由两个重叠矩形组成的简洁 App 图标。
- Added reproducible SVG-to-ICNS icon generation scripts. / 新增可复现的 SVG 到 ICNS 图标生成脚本。

## 3.0.0

- Added Chinese and English UI switching. / 新增中英文界面切换。
- Added bilingual long-edge and short-edge guidance. / 新增长边、短边双语说明。
- Replaced the built-in PDF with an explicit orientation test. / 使用方向标记明确的新版内置测试 PDF。
- Added automatic fallback detection for print queue names containing `1020`. / 新增对名称中含 `1020` 的打印队列自动识别。
- Built as an Apple silicon and Intel universal binary. / 构建为 Apple 芯片与 Intel 通用程序。
- Preserved the confirmed two-stage reload workflow and corrected page ordering. / 保留已经验证的两阶段放纸确认流程与正确页序。
