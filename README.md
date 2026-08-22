# HP1020 Manual Duplex for macOS

[简体中文](README.zh-CN.md)

A small native macOS helper for manual two-sided printing with the HP LaserJet 1020 / 1020 Plus. It does not install or redistribute an HP printer driver. It prepares odd and even PDF pages, submits the first side, waits for a confirmed paper reload, and then submits the second side.

## Features

- Chinese and English UI with a bilingual **语言 / Language** switch fixed at the upper-right corner.
- A simple native app icon showing two overlapping sheets.
- Long-edge binding for book-style left-to-right page turning.
- Short-edge binding for calendar-style top-to-bottom page turning.
- All-pages or contiguous page-range printing, with correct duplex pairing even when the selected range starts on an even-numbered source page.
- Choosing or opening a PDF only selects it. Printing starts only after the separate **Start Printing** button is clicked.
- Successful single-page and duplex completion is shown in the status line without an extra pop-up. Error alerts are retained.
- A real two-stage workflow: the second print job is not created until the reload checkbox is selected.
- A bilingual two-page orientation test with large top-edge markers.
- Automatic fallback to an installed print queue whose name contains `1020`.
- Universal macOS binary for Apple silicon and Intel.

## Requirements

- macOS 13 or later.
- A working HP LaserJet 1020 / 1020 Plus print queue. The printer driver and any required firmware loader must already be installed.
- `qpdf`, normally installed with `brew install qpdf`.
- A4 paper. Version 4 submits print jobs with A4 and fit-to-page options.

The app first tries the queue name `HP_LaserJet_1020`. If that queue is unavailable, it uses the first available queue whose name contains `1020`.

## Printer driver setup

This project is a manual-duplex helper, not a printer driver. The HP 1020 must already print normally from macOS before this app can work.

For a compact community-maintained driver setup for modern macOS, see [anxkhn/hp1020-driver-mac](https://github.com/anxkhn/hp1020-driver-mac/blob/main/README.md). That project documents a setup based on selected components from Apple's HP Printer Drivers 5.1.1 package and the compatible LaserJet 1022 PPD.

The driver files are not included or redistributed here. Follow the referenced project's installation and permission instructions separately, then confirm that the `HP_LaserJet_1020` queue can print a normal PDF before using this app.

## Use

1. Select Chinese or English.
2. Select the binding direction.
3. Click **Choose PDF**. Selecting the file does not print it.
4. Select **All pages** or **Page range**. For a range, enter the first and/or last source-PDF page; a blank field means the first or last page.
5. Click **Start Printing**. Alternatively, **Run Orientation Test** immediately prints both built-in test pages and ignores the range setting.
6. Wait until the first side finishes completely.
7. Remove the entire printed stack without changing its page order.
8. Reload it printed-side down, feeding the bottom edge into the tray first.
9. Select the confirmation checkbox and click **Print Second Side**.

Binding direction matters:

- **Long edge:** flip left to right like a book. Both sides should be upright.
- **Short edge:** flip top to bottom like a calendar. When the two printed faces are compared directly, their content is intentionally 180 degrees apart.

## Build

Open Terminal in the project directory and run:

```sh
./Scripts/build.sh
```

The app is created at `build/HP1020 Manual Duplex.app`. The build script produces an Apple silicon + Intel universal binary and applies an ad-hoc signature.

The generated `Resources/AppIcon.icns` is included in the repository, so ImageMagick is not required for a normal build. To regenerate it from the editable SVG source, install ImageMagick and run:

```sh
brew install imagemagick
./Scripts/make_app_icon.sh
```

To regenerate the built-in bilingual test PDF, install ReportLab and run:

```sh
python3 -m pip install reportlab
python3 Scripts/make_test_pdf.py Resources/two-page-test.pdf
```

## Release status

- Version 4 is ad-hoc signed, not Apple-notarized. Build from source if macOS does not allow the downloaded app to open.
- No open-source license has been selected yet. Source is visible for inspection, but no reuse rights are granted until the repository owner adds a license.
- The core manual-duplex workflow has been physically tested on Apple silicon with an HP LaserJet 1020. Page-range ordering and the version 4 interface have been verified without submitting a print job; a physical page-range print test and additional Intel-device testing are still recommended.
- Apple and HP printer-driver files are intentionally not bundled or redistributed.

## Privacy

All PDF processing and printing are local. The app has no analytics and makes no network requests.

## Acknowledgements

Driver installation reference: [anxkhn/hp1020-driver-mac](https://github.com/anxkhn/hp1020-driver-mac/blob/main/README.md).

HP and LaserJet are trademarks of HP Inc. This project is an independent compatibility utility and is not affiliated with or endorsed by HP.
