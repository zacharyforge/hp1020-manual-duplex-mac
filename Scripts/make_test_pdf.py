#!/usr/bin/env python3
"""Generate the ink-saving bilingual HP1020 duplex orientation test PDF."""

from __future__ import annotations

import argparse
from pathlib import Path

from reportlab.lib.colors import HexColor, black
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfgen import canvas


WIDTH, HEIGHT = A4
ZH_FONT = "STSong-Light"


def centered(c: canvas.Canvas, text: str, y: float, font: str, size: float, color=black) -> None:
    c.setFont(font, size)
    c.setFillColor(color)
    c.drawCentredString(WIDTH / 2, y, text)


def draw_outline_arrow(
    c: canvas.Canvas,
    center_x: float,
    bottom: float,
    top: float,
    color,
    shaft_width: float = 30,
    head_width: float = 92,
    head_height: float = 66,
    line_width: float = 6,
) -> None:
    """Draw one continuous hollow arrow outline to minimize toner use."""
    half_shaft = shaft_width / 2
    half_head = head_width / 2
    shoulder_y = top - head_height
    path = c.beginPath()
    path.moveTo(center_x, top)
    path.lineTo(center_x - half_head, shoulder_y)
    path.lineTo(center_x - half_shaft, shoulder_y)
    path.lineTo(center_x - half_shaft, bottom)
    path.lineTo(center_x + half_shaft, bottom)
    path.lineTo(center_x + half_shaft, shoulder_y)
    path.lineTo(center_x + half_head, shoulder_y)
    path.close()
    c.setStrokeColor(color)
    c.setLineWidth(line_width)
    c.setLineJoin(1)
    c.drawPath(path, stroke=1, fill=0)


def outline_box(c: canvas.Canvas, x: float, y: float, width: float, height: float, color) -> None:
    c.setStrokeColor(color)
    c.setLineWidth(1.25)
    c.roundRect(x, y, width, height, 12, stroke=1, fill=0)


def page_shell(c: canvas.Canvas, accent, side_number: int, side_en: str, side_zh: str) -> None:
    c.setStrokeColor(accent)
    c.setLineWidth(2)
    c.roundRect(36, 30, WIDTH - 72, HEIGHT - 60, 12, stroke=1, fill=0)

    # Edge markers are lines and text only: no solid toner-heavy bands.
    c.setLineWidth(1.2)
    c.line(60, HEIGHT - 52, WIDTH - 60, HEIGHT - 52)
    centered(c, "TOP EDGE", HEIGHT - 76, "Helvetica-Bold", 13, accent)
    centered(c, "纸张顶边", HEIGHT - 97, ZH_FONT, 12, accent)
    c.line(60, HEIGHT - 108, WIDTH - 60, HEIGHT - 108)

    c.line(60, 77, WIDTH - 60, 77)
    centered(c, "BOTTOM EDGE", 55, "Helvetica-Bold", 10.5, HexColor("#4D535B"))
    centered(c, "纸张底边", 38, ZH_FONT, 10.5, HexColor("#4D535B"))

    centered(c, "HP LASERJET 1020", HEIGHT - 137, "Helvetica-Bold", 14, HexColor("#353A40"))
    centered(c, "MANUAL DUPLEX ORIENTATION TEST", HEIGHT - 167, "Helvetica-Bold", 20, accent)
    centered(c, "手动双面方向测试", HEIGHT - 195, ZH_FONT, 17, accent)

    # English and Chinese are deliberately separated so each uses its own font.
    centered(c, f"SIDE {side_number}", HEIGHT - 252, "Helvetica-Bold", 35, accent)
    centered(c, f"第 {side_number} 面", HEIGHT - 286, ZH_FONT, 25, accent)
    centered(c, side_en, HEIGHT - 318, "Helvetica-Bold", 14, HexColor("#555D66"))
    centered(c, side_zh, HEIGHT - 340, ZH_FONT, 13, HexColor("#555D66"))


def make_pdf(output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    pdfmetrics.registerFont(UnicodeCIDFont(ZH_FONT))
    c = canvas.Canvas(str(output), pagesize=A4, pageCompression=1)
    c.setTitle("HP1020 Manual Duplex Orientation Test / 手动双面方向测试")
    c.setAuthor("HP1020 Manual Duplex")
    c.setSubject("Bilingual long-edge and short-edge manual duplex verification")

    blue = HexColor("#244E84")
    green = HexColor("#236B4A")
    muted = HexColor("#4F5864")

    page_shell(c, blue, 1, "FRONT", "正面")
    draw_outline_arrow(c, WIDTH / 2, 348, 492, blue)
    centered(c, "THIS WAY UP", 318, "Helvetica-Bold", 17, blue)
    centered(c, "此方向向上", 292, ZH_FONT, 16, blue)

    outline_box(c, 74, 103, WIDTH - 148, 142, blue)
    centered(c, "Print this side first, then wait for the reload prompt.", 212, "Helvetica-Bold", 13.5, black)
    centered(c, "先打印本面，然后等待程序提示重新放纸。", 184, ZH_FONT, 13.5, black)
    centered(c, "Do not continue until the paper has been reloaded.", 151, "Helvetica", 12.5, muted)
    centered(c, "纸张未重新放好之前，不要打印第二面。", 124, ZH_FONT, 12.5, muted)
    c.showPage()

    page_shell(c, green, 2, "BACK", "背面")
    draw_outline_arrow(c, WIDTH / 2, 378, 492, green, line_width=5.5)
    centered(c, "THIS WAY UP", 348, "Helvetica-Bold", 16, green)
    centered(c, "此方向向上", 323, ZH_FONT, 15, green)
    centered(c, "UPRIGHT AFTER THE SELECTED FLIP = PASS", 291, "Helvetica-Bold", 11, green)
    centered(c, "按所选装订方向翻页后文字正立 = 通过", 268, ZH_FONT, 11, green)

    box_y = 91
    box_h = 153
    gap = 18
    box_w = (WIDTH - 148 - gap) / 2
    left_x = 65
    right_x = left_x + box_w + gap
    outline_box(c, left_x, box_y, box_w, box_h, green)
    outline_box(c, right_x, box_y, box_w, box_h, green)

    left_center = left_x + box_w / 2
    right_center = right_x + box_w / 2

    c.setFillColor(black)
    c.setFont("Helvetica-Bold", 13)
    c.drawCentredString(left_center, 216, "LONG EDGE")
    c.setFont(ZH_FONT, 13)
    c.drawCentredString(left_center, 191, "长边装订")
    c.setFillColor(muted)
    c.setFont("Helvetica", 11.5)
    c.drawCentredString(left_center, 157, "Flip left to right")
    c.drawCentredString(left_center, 140, "like a book.")
    c.setFont(ZH_FONT, 11.5)
    c.drawCentredString(left_center, 112, "像书一样左右翻页。")

    c.setFillColor(black)
    c.setFont("Helvetica-Bold", 13)
    c.drawCentredString(right_center, 216, "SHORT EDGE")
    c.setFont(ZH_FONT, 13)
    c.drawCentredString(right_center, 191, "短边装订")
    c.setFillColor(muted)
    c.setFont("Helvetica", 11.5)
    c.drawCentredString(right_center, 157, "Flip top to bottom")
    c.drawCentredString(right_center, 140, "like a calendar.")
    c.setFont("Helvetica", 9.8)
    c.drawCentredString(right_center, 124, "A 180° difference between faces is normal.")
    c.setFont(ZH_FONT, 10.5)
    c.drawCentredString(right_center, 103, "直接比较两面时相差 180° 是正常的。")
    c.showPage()
    c.save()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "output",
        nargs="?",
        default="outputs/HP1020手动双面测试.pdf",
        type=Path,
        help="output PDF path",
    )
    args = parser.parse_args()
    make_pdf(args.output)


if __name__ == "__main__":
    main()
