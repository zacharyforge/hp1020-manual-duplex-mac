# HP1020 Manual Duplex 3.0.0

## English

The first public-ready build of the native macOS manual-duplex helper for HP LaserJet 1020 / 1020 Plus.

### Highlights

- Chinese and English UI with an in-app language switch.
- Long-edge and short-edge binding with plain-language flip guidance.
- Safe two-stage printing: the second-side job is created only after the user confirms the paper reload.
- Correct odd-page and reverse-even-page ordering, including odd-length documents.
- Bilingual, ink-saving two-page orientation test with hollow arrows and explicit top/bottom edge labels.
- Automatic fallback detection for installed print queue names containing `1020`.
- Universal app binary for Apple silicon and Intel Macs.

### Requirements

- macOS 13 or later.
- A working HP LaserJet 1020 / 1020 Plus print queue.
- `qpdf` installed, normally with `brew install qpdf`.

This app does not include a printer driver. For a modern macOS community driver setup, see [anxkhn/hp1020-driver-mac](https://github.com/anxkhn/hp1020-driver-mac/blob/main/README.md).

The downloadable app is ad-hoc signed and is not Apple-notarized. Source is included in the repository for inspection and local builds.

## 中文

这是 HP LaserJet 1020 / 1020 Plus 原生 macOS 手动双面打印辅助程序的首个公开发布准备版本。

### 主要功能

- 中文、英文界面，可在程序内切换。
- 支持长边和短边装订，并直接说明正确翻页方向。
- 安全的两阶段打印流程：只有用户确认重新放纸后，程序才创建第二面任务。
- 正确处理奇数页和逆序偶数页，包括总页数为奇数的文档。
- 双语省墨方向测试页，采用空心箭头和明确的纸张顶边、底边标记。
- 标准打印队列不可用时，自动寻找名称中含 `1020` 的队列。
- 同时支持 Apple 芯片和 Intel Mac 的通用程序。

### 使用条件

- macOS 13 或更高版本。
- 已经能够正常打印的 HP LaserJet 1020 / 1020 Plus 队列。
- 已安装 `qpdf`，通常可使用 `brew install qpdf` 安装。

本程序不包含打印机驱动。现代 macOS 社区驱动安装方案请参考 [anxkhn/hp1020-driver-mac](https://github.com/anxkhn/hp1020-driver-mac/blob/main/README.md)。

下载版应用使用临时签名，尚未通过 Apple 公证。仓库中提供完整源码，可供检查和本机构建。
