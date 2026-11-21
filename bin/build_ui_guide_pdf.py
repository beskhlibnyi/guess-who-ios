#!/usr/bin/env python3
"""Build the YALIAS visual identity and UI guide PDF."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import Paragraph


ROOT = Path(__file__).resolve().parents[1]
SOURCE_IMAGE = ROOT / "docs" / "assets" / "yalias-ui-direction.png"
OUTPUT = ROOT / "output" / "pdf" / "YALIAS_UI_Guide.pdf"
TMP = ROOT / "tmp" / "pdfs" / "yalias_ui_guide"

PAGE_W, PAGE_H = landscape(A4)
MARGIN = 40


def hx(value: str) -> colors.Color:
    return colors.HexColor(value)


PALETTE = {
    "canvas": hx("#F2E1C8"),
    "paper": hx("#FFF3DE"),
    "paper_high": hx("#FFF9EF"),
    "ink": hx("#211E19"),
    "ink_soft": hx("#514A41"),
    "olive": hx("#5F7A2D"),
    "olive_accessible": hx("#49621F"),
    "mustard": hx("#F2B51D"),
    "vermilion": hx("#D94A32"),
    "vermilion_accessible": hx("#A93A2A"),
    "sky": hx("#78AED0"),
    "sage": hx("#9BAA58"),
    "line": hx("#302B24"),
    "white": hx("#FFF8EB"),
}


TITLE = ParagraphStyle(
    "title",
    fontName="Helvetica-Bold",
    fontSize=27,
    leading=31,
    textColor=PALETTE["ink"],
    spaceAfter=0,
)
SUBTITLE = ParagraphStyle(
    "subtitle",
    fontName="Helvetica",
    fontSize=12,
    leading=17,
    textColor=PALETTE["ink_soft"],
)
BODY = ParagraphStyle(
    "body",
    fontName="Helvetica",
    fontSize=10,
    leading=14,
    textColor=PALETTE["ink"],
)
BODY_SMALL = ParagraphStyle(
    "body-small",
    fontName="Helvetica",
    fontSize=8.6,
    leading=12,
    textColor=PALETTE["ink_soft"],
)
CAPTION = ParagraphStyle(
    "caption",
    fontName="Helvetica-Bold",
    fontSize=7.5,
    leading=10,
    textColor=PALETTE["ink_soft"],
)


def para(c: Canvas, text: str, x: float, y_top: float, width: float, style=BODY) -> float:
    p = Paragraph(text, style)
    _, height = p.wrap(width, PAGE_H)
    p.drawOn(c, x, y_top - height)
    return height


def page_base(c: Canvas, number: int, section: str, dark: bool = False) -> None:
    c.setFillColor(PALETTE["ink"] if dark else PALETTE["canvas"])
    c.rect(0, 0, PAGE_W, PAGE_H, stroke=0, fill=1)
    c.setFillColor(PALETTE["mustard"])
    c.circle(22, PAGE_H - 20, 42, stroke=0, fill=1)
    c.setFillColor(PALETTE["sky"])
    c.circle(PAGE_W - 18, 12, 54, stroke=0, fill=1)
    c.setStrokeColor(PALETTE["paper"] if dark else PALETTE["line"])
    c.setLineWidth(0.8)
    c.line(MARGIN, 24, PAGE_W - MARGIN, 24)
    c.setFont("Helvetica-Bold", 7)
    c.setFillColor(PALETTE["paper"] if dark else PALETTE["ink_soft"])
    c.drawString(MARGIN, 11, f"YALIAS VISUAL IDENTITY / {section.upper()}")
    c.drawRightString(PAGE_W - MARGIN, 11, f"{number:02d}")


def page_title(c: Canvas, title: str, eyebrow: str, subtitle: str = "") -> None:
    c.setFont("Helvetica-Bold", 8)
    c.setFillColor(PALETTE["vermilion"])
    c.drawString(MARGIN, PAGE_H - 48, eyebrow.upper())
    title_height = para(c, title, MARGIN, PAGE_H - 58, PAGE_W - (2 * MARGIN), TITLE)
    if subtitle:
        para(c, subtitle, MARGIN, PAGE_H - 64 - title_height, PAGE_W - (2 * MARGIN), SUBTITLE)


def paper_panel(
    c: Canvas,
    x: float,
    y: float,
    w: float,
    h: float,
    radius: float = 18,
    fill=None,
    stroke=None,
    shadow: bool = True,
) -> None:
    if shadow:
        c.setFillColor(colors.Color(0.25, 0.18, 0.12, alpha=0.10))
        c.roundRect(x + 3, y - 4, w, h, radius, stroke=0, fill=1)
    c.setFillColor(fill or PALETTE["paper"])
    c.setStrokeColor(stroke or colors.Color(0.19, 0.17, 0.14, alpha=0.22))
    c.setLineWidth(0.8)
    c.roundRect(x, y, w, h, radius, stroke=1, fill=1)


def label(c: Canvas, text: str, x: float, y: float, color=None, size: float = 8) -> None:
    c.setFont("Helvetica-Bold", size)
    c.setFillColor(color or PALETTE["ink_soft"])
    c.drawString(x, y, text.upper())


def bullet(c: Canvas, text: str, x: float, y_top: float, width: float, accent=None) -> float:
    c.setFillColor(accent or PALETTE["vermilion"])
    c.circle(x + 4, y_top - 6, 3, stroke=0, fill=1)
    return para(c, text, x + 14, y_top, width - 14, BODY)


def image_crop(source: Path, name: str, box: tuple[int, int, int, int]) -> Path:
    TMP.mkdir(parents=True, exist_ok=True)
    destination = TMP / name
    with Image.open(source) as image:
        image.crop(box).save(destination, quality=95)
    return destination


def draw_image_cover(c: Canvas, path: Path, x: float, y: float, w: float, h: float, radius=26) -> None:
    with Image.open(path) as image:
        iw, ih = image.size
    scale = max(w / iw, h / ih)
    draw_w, draw_h = iw * scale, ih * scale
    c.saveState()
    clip = c.beginPath()
    clip.roundRect(x, y, w, h, radius)
    c.clipPath(clip, stroke=0)
    c.drawImage(ImageReader(str(path)), x + (w - draw_w) / 2, y + (h - draw_h) / 2, draw_w, draw_h)
    c.restoreState()
    c.setStrokeColor(PALETTE["line"])
    c.setLineWidth(1.5)
    c.roundRect(x, y, w, h, radius, stroke=1, fill=0)


def swatch(c: Canvas, x: float, y: float, w: float, h: float, name: str, hex_value: str, usage: str) -> None:
    color = hx(hex_value)
    c.setFillColor(color)
    c.roundRect(x, y, w, h, 14, stroke=0, fill=1)
    brightness = 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
    ink = PALETTE["paper_high"] if brightness < 0.55 else PALETTE["ink"]
    c.setFillColor(ink)
    c.setFont("Helvetica-Bold", 10)
    c.drawString(x + 12, y + h - 19, name)
    c.setFont("Helvetica", 8)
    c.drawString(x + 12, y + h - 33, hex_value)
    para(c, usage, x + 12, y + h - 43, w - 24, ParagraphStyle(
        "swatch",
        parent=BODY_SMALL,
        textColor=ink,
        fontSize=7.5,
        leading=10,
    ))


def draw_mode_control(c: Canvas, x: float, y: float, w: float, h: float) -> None:
    c.setFillColor(PALETTE["paper_high"])
    c.setStrokeColor(PALETTE["line"])
    c.setLineWidth(1.7)
    c.roundRect(x, y, w, h, h / 2, stroke=1, fill=1)
    c.setFillColor(PALETTE["olive"])
    c.roundRect(x + 3, y + 3, w / 2 - 3, h - 6, (h - 6) / 2, stroke=0, fill=1)
    c.setFont("Helvetica-Bold", 13)
    c.setFillColor(PALETTE["white"])
    c.drawCentredString(x + w * 0.25, y + h / 2 - 5, "Classic")
    c.setFillColor(PALETTE["ink"])
    c.drawCentredString(x + w * 0.75, y + h / 2 - 5, "Fastest")


def draw_slider(c: Canvas, x: float, y: float, w: float, progress: float, title: str, value: str) -> None:
    c.setFont("Helvetica-Bold", 9)
    c.setFillColor(PALETTE["ink"])
    c.drawString(x, y + 25, title)
    c.drawRightString(x + w, y + 25, value)
    track_y = y + 8
    c.setStrokeColor(PALETTE["line"])
    c.setLineWidth(1.5)
    c.setFillColor(PALETTE["paper_high"])
    c.roundRect(x, track_y, w, 10, 5, stroke=1, fill=1)
    c.setFillColor(PALETTE["olive"])
    c.roundRect(x + 1, track_y + 1, max(8, w * progress), 8, 4, stroke=0, fill=1)
    thumb_x = x + w * progress
    c.setFillColor(PALETTE["mustard"])
    c.setStrokeColor(PALETTE["line"])
    c.setLineWidth(1.4)
    c.circle(thumb_x, track_y + 5, 9, stroke=1, fill=1)


def draw_chip(c: Canvas, x: float, y: float, w: float, text: str, fill, selected: bool = False) -> None:
    if selected:
        c.setFillColor(PALETTE["paper_high"])
        c.roundRect(x - 3, y - 3, w + 6, 34, 15, stroke=0, fill=1)
    c.setFillColor(fill)
    c.roundRect(x, y, w, 28, 13, stroke=0, fill=1)
    c.setFont("Helvetica-Bold", 9)
    c.setFillColor(PALETTE["ink"])
    c.drawCentredString(x + w / 2, y + 9, text)


def draw_toggle(c: Canvas, x: float, y: float, on: bool = True) -> None:
    c.setFillColor(PALETTE["olive"] if on else hx("#CFC4B4"))
    c.roundRect(x, y, 58, 28, 14, stroke=0, fill=1)
    c.setFillColor(PALETTE["paper_high"])
    c.circle(x + (43 if on else 15), y + 14, 12, stroke=0, fill=1)


def draw_button(c: Canvas, x: float, y: float, w: float, h: float, text: str, primary=True) -> None:
    if primary:
        c.setFillColor(PALETTE["vermilion"])
        c.setStrokeColor(PALETTE["vermilion"])
        text_color = PALETTE["paper_high"]
    else:
        c.setFillColor(PALETTE["paper_high"])
        c.setStrokeColor(PALETTE["line"])
        text_color = PALETTE["ink"]
    c.setLineWidth(1.6)
    c.roundRect(x, y, w, h, h / 2, stroke=1, fill=1)
    c.setFont("Helvetica-Bold", 12)
    c.setFillColor(text_color)
    c.drawCentredString(x + w / 2, y + h / 2 - 4, text)


def cover(c: Canvas, image_path: Path) -> None:
    c.setFillColor(PALETTE["ink"])
    c.rect(0, 0, PAGE_W, PAGE_H, stroke=0, fill=1)
    c.setFillColor(PALETTE["mustard"])
    c.circle(-5, PAGE_H + 5, 130, stroke=0, fill=1)
    c.setFillColor(PALETTE["sky"])
    c.circle(PAGE_W - 6, 3, 120, stroke=0, fill=1)
    c.setFillColor(PALETTE["vermilion"])
    c.circle(48, 14, 46, stroke=0, fill=1)
    draw_image_cover(c, image_path, PAGE_W - 320, 38, 270, PAGE_H - 76, 30)
    c.setFillColor(PALETTE["paper_high"])
    c.setFont("Helvetica-Bold", 11)
    c.drawString(58, PAGE_H - 86, "VISUAL IDENTITY + UI SYSTEM")
    c.setFont("Helvetica-Bold", 42)
    c.drawString(58, PAGE_H - 150, "YALIAS")
    c.setFont("Helvetica", 18)
    c.drawString(58, PAGE_H - 180, "Handmade energy. Clear play.")
    para(
        c,
        "A working guide for translating the selected paper-and-ink direction into a consistent, accessible SwiftUI product.",
        58,
        PAGE_H - 225,
        390,
        ParagraphStyle("cover-body", parent=SUBTITLE, textColor=PALETTE["paper"], fontSize=13, leading=19),
    )
    c.setFillColor(PALETTE["paper"])
    c.setFont("Helvetica", 9)
    c.drawString(58, 58, "VERSION 1.0 / NOVEMBER 2026")
    c.showPage()


def brand_core(c: Canvas) -> None:
    page_base(c, 2, "Brand core")
    page_title(c, "A social game that feels made by hand", "01 / Brand core", "The visual system should feel warm, immediate, and human - never polished into generic app minimalism.")
    cards = [
        ("PLAYFUL, NOT CHILDISH", "Expressive ink, color, and irregular edges create joy. Controls stay ordered and adult."),
        ("TACTILE, NOT HEAVY", "Paper layers and shallow shadows suggest touch. Texture never competes with words or scores."),
        ("LOCAL, NOT LITERAL", "Ukrainian character comes through print culture, language, and color rhythm - not flags or costume motifs."),
        ("FAST, NOT CHAOTIC", "During play, hierarchy wins: one word, one timer, one clear action at a time."),
    ]
    positions = [(42, 294), (423, 294), (42, 128), (423, 128)]
    accents = [PALETTE["olive"], PALETTE["mustard"], PALETTE["sky"], PALETTE["vermilion"]]
    for (heading, body), (x, y), accent in zip(cards, positions, accents):
        paper_panel(c, x, y, 350, 132, 20)
        c.setFillColor(accent)
        c.circle(x + 30, y + 97, 16, stroke=0, fill=1)
        c.setFont("Helvetica-Bold", 11)
        c.setFillColor(PALETTE["ink"])
        c.drawString(x + 56, y + 94, heading)
        para(c, body, x + 26, y + 73, 298, BODY)
    c.showPage()


def logo_page(c: Canvas, logo_crop: Path) -> None:
    page_base(c, 3, "Logo")
    page_title(c, "The wordmark is a crafted asset", "02 / Logo", "Treat the hand-painted logo as artwork. Do not recreate it with a runtime font or recolor it per screen.")
    paper_panel(c, 40, 188, 410, 300, 24)
    c.drawImage(ImageReader(str(logo_crop)), 65, 222, 360, 230, preserveAspectRatio=True, anchor="c", mask="auto")
    label(c, "Primary lockup", 60, 202)
    paper_panel(c, 480, 330, 320, 158, 20)
    label(c, "Required behavior", 504, 454, PALETTE["vermilion"])
    y = 432
    for item in [
        "Keep YALIAS letters black.",
        "Keep the yellow and red speech bubbles paired.",
        "Keep the mustard underline as part of the mark.",
        "Use generous clear space: at least half the cap height.",
    ]:
        h = bullet(c, item, 500, y, 270, PALETTE["olive"])
        y -= h + 8
    paper_panel(c, 480, 188, 320, 116, 20)
    label(c, "Do not", 504, 272, PALETTE["vermilion"])
    para(c, "Do not stretch, add outlines, animate individual letters, put the mark on busy photography, or reuse the speech bubbles as random decoration.", 504, 250, 270, BODY_SMALL)
    c.showPage()


def color_page(c: Canvas) -> None:
    page_base(c, 4, "Color")
    page_title(c, "Warm paper, black ink, four accents", "03 / Color", "The palette is broad enough for game states, but each screen should use one dominant accent plus one supporting accent.")
    data = [
        ("Canvas", "#F2E1C8", "App background and exposed edge."),
        ("Paper", "#FFF3DE", "Cards, controls, and text surfaces."),
        ("Ink", "#211E19", "Primary text, outlines, and icons."),
        ("Olive", "#5F7A2D", "Selection, success, active tracks."),
        ("Mustard", "#F2B51D", "Thumbs, highlights, attention."),
        ("Vermilion", "#D94A32", "Primary action and urgency."),
        ("Sky", "#78AED0", "Easy level and supporting accent."),
        ("Sage", "#9BAA58", "Expert level and calm support."),
    ]
    start_x, start_y = 40, 332
    sw, sh, gap_x, gap_y = 178, 105, 20, 22
    for index, (name, code, usage) in enumerate(data):
        row, col = divmod(index, 4)
        swatch(c, start_x + col * (sw + gap_x), start_y - row * (sh + gap_y), sw, sh, name, code, usage)
    paper_panel(c, 40, 76, 760, 96, 18)
    label(c, "Accessibility rule", 60, 142, PALETTE["vermilion"])
    para(c, "Use Ink on Paper, Mustard, Sky, and Sage. Use Cream text only on Olive 700 (#49621F) or Vermilion 700 (#A93A2A) for small labels. The brighter mockup colors are reserved for large text, decoration, and filled surfaces.", 60, 125, 720, BODY)
    c.showPage()


def typography_page(c: Canvas) -> None:
    page_base(c, 5, "Typography")
    page_title(c, "Expressive brand, disciplined interface", "04 / Typography", "Hand lettering creates identity. Functional controls use a consistent system font so English and Ukrainian remain equally readable.")
    paper_panel(c, 40, 294, 365, 194, 22)
    label(c, "Brand artwork", 62, 455, PALETTE["vermilion"])
    c.setFont("Helvetica-Bold", 36)
    c.setFillColor(PALETTE["ink"])
    c.drawString(62, 398, "YALIAS")
    c.setStrokeColor(PALETTE["mustard"])
    c.setLineWidth(8)
    c.setLineCap(1)
    c.line(63, 381, 215, 381)
    para(c, "The primary wordmark is artwork. Yakutovych may support Ukrainian display moments, but it must not replace the approved logo asset.", 62, 360, 315, BODY_SMALL)
    paper_panel(c, 430, 294, 370, 194, 22)
    label(c, "Functional UI", 452, 455, PALETTE["olive"])
    c.setFont("Helvetica-Bold", 24)
    c.setFillColor(PALETTE["ink"])
    c.drawString(452, 408, "Avenir Next Demi Bold")
    c.setFont("Helvetica", 13)
    c.drawString(452, 377, "Avenir Next Regular for body and help text")
    c.setFont("Helvetica-Bold", 18)
    c.drawString(452, 342, "30 points  /  60 sec")
    paper_panel(c, 40, 112, 760, 146, 22)
    specs = [
        ("Display", "34-44 pt", "Heavy", "Results, handoff, current word"),
        ("Title", "22-28 pt", "Demi Bold", "Screen and card titles"),
        ("Body", "17 pt", "Regular", "Instructions and descriptions"),
        ("Button", "18-22 pt", "Demi Bold", "Primary and secondary actions"),
        ("Label", "12-14 pt", "Demi Bold", "Control names and metadata"),
    ]
    x = 60
    for role, size, weight, use in specs:
        c.setFont("Helvetica-Bold", 9)
        c.setFillColor(PALETTE["ink"])
        c.drawString(x, 224, role)
        c.setFont("Helvetica", 8)
        c.setFillColor(PALETTE["ink_soft"])
        c.drawString(x, 207, size)
        c.drawString(x, 194, weight)
        para(c, use, x, 180, 125, BODY_SMALL)
        x += 145
    c.showPage()


def materials_page(c: Canvas) -> None:
    page_base(c, 6, "Materials and layout")
    page_title(c, "Build the feeling from layers, not images", "05 / Materials", "The app should remain responsive and localizable. Use live SwiftUI surfaces with a restrained shared texture overlay.")
    paper_panel(c, 40, 250, 455, 238, 24)
    label(c, "Layer recipe", 62, 455, PALETTE["vermilion"])
    layers = [
        ("01", "Canvas", "Warm cream base plus 3-5% paper grain."),
        ("02", "Paper surface", "Brighter cream card with a shallow warm shadow."),
        ("03", "Ink edge", "1-2 pt irregular dark outline on key controls only."),
        ("04", "Accent fill", "Flat color plus no more than 5% texture variation."),
    ]
    y = 421
    for number, name, desc in layers:
        c.setFillColor(PALETTE["mustard"])
        c.circle(76, y + 2, 14, stroke=0, fill=1)
        c.setFillColor(PALETTE["ink"])
        c.setFont("Helvetica-Bold", 8)
        c.drawCentredString(76, y - 1, number)
        c.setFont("Helvetica-Bold", 10)
        c.drawString(100, y + 5, name)
        c.setFont("Helvetica", 8.5)
        c.setFillColor(PALETTE["ink_soft"])
        c.drawString(100, y - 9, desc)
        y -= 50
    paper_panel(c, 520, 250, 280, 238, 24)
    label(c, "Geometry", 542, 455, PALETTE["olive"])
    metrics = [
        ("Base spacing", "8 pt"),
        ("Screen gutter", "20 pt"),
        ("Card padding", "20-24 pt"),
        ("Control height", "52-60 pt"),
        ("Large radius", "24-30 pt"),
        ("Pill radius", "50% height"),
        ("Minimum target", "44 x 44 pt"),
    ]
    y = 425
    for name, value in metrics:
        c.setFont("Helvetica", 9)
        c.setFillColor(PALETTE["ink_soft"])
        c.drawString(542, y, name)
        c.setFont("Helvetica-Bold", 9)
        c.setFillColor(PALETTE["ink"])
        c.drawRightString(774, y, value)
        c.setStrokeColor(colors.Color(0.19, 0.17, 0.14, alpha=0.18))
        c.line(542, y - 8, 774, y - 8)
        y -= 27
    paper_panel(c, 40, 94, 760, 120, 20)
    label(c, "Texture guardrail", 62, 182, PALETTE["vermilion"])
    para(c, "Texture is decorative and must never encode state. Keep it static during gameplay, exclude it from text glyphs, and reduce it automatically when Increase Contrast is enabled. The current generated mockup is a direction reference - production UI should be constructed from live components.", 62, 160, 710, BODY)
    c.showPage()


def components_page(c: Canvas) -> None:
    page_base(c, 7, "Core components")
    page_title(c, "One visual grammar for every setup control", "06 / Components", "Use repeatable geometry and state rules. Handmade character belongs in edges and texture, not inconsistent sizing.")
    paper_panel(c, 40, 270, 360, 190, 22)
    label(c, "Mode selector", 62, 428, PALETTE["olive"])
    draw_mode_control(c, 68, 346, 300, 54)
    para(c, "Selected side uses Olive with Cream text. The control animates the fill position in 220 ms; labels never move.", 68, 326, 300, BODY_SMALL)
    paper_panel(c, 425, 270, 375, 190, 22)
    label(c, "Value sliders", 447, 428, PALETTE["mustard"])
    draw_slider(c, 452, 366, 320, 0.38, "Goal", "30 points")
    draw_slider(c, 452, 308, 320, 0.61, "Turn time", "60 sec")
    paper_panel(c, 40, 86, 360, 154, 22)
    label(c, "Difficulty chips", 62, 208, PALETTE["sky"])
    draw_chip(c, 62, 148, 68, "Easy", PALETTE["sky"])
    draw_chip(c, 140, 148, 82, "Medium", PALETTE["mustard"], True)
    draw_chip(c, 235, 148, 68, "Hard", PALETTE["vermilion"])
    draw_chip(c, 312, 148, 68, "Expert", PALETTE["sage"])
    para(c, "Color identifies level; outline and selection elevation confirm state without relying on color alone.", 62, 128, 300, BODY_SMALL)
    paper_panel(c, 425, 86, 375, 154, 22)
    label(c, "Toggle row", 447, 208, PALETTE["olive"])
    c.setFont("Helvetica-Bold", 12)
    c.setFillColor(PALETTE["ink"])
    c.drawString(452, 162, "Include adjectives")
    draw_toggle(c, 704, 150, True)
    para(c, "Make the complete row tappable. Keep the switch visual familiar even when the surface is handmade.", 452, 128, 310, BODY_SMALL)
    c.showPage()


def actions_states_page(c: Canvas) -> None:
    page_base(c, 8, "Actions and states")
    page_title(c, "Strong primary action, quiet secondary action", "07 / Actions", "Vermilion is reserved for the next decisive step. Destructive actions use a confirmation dialog and never borrow this playful button treatment.")
    paper_panel(c, 40, 286, 355, 174, 22)
    label(c, "Primary", 62, 428, PALETTE["vermilion"])
    draw_button(c, 70, 348, 295, 58, "Start game", True)
    para(c, "One per screen. Full width. Minimum 58 pt. Cream label. Press: scale to 0.985 and reduce shadow.", 70, 327, 295, BODY_SMALL)
    paper_panel(c, 420, 286, 380, 174, 22)
    label(c, "Secondary", 442, 428, PALETTE["ink_soft"])
    draw_button(c, 460, 348, 300, 52, "Review words", False)
    para(c, "Outline or text treatment. It must not compete with Start, Resume, Continue, or Rematch.", 460, 327, 300, BODY_SMALL)
    paper_panel(c, 40, 82, 760, 170, 22)
    label(c, "State matrix", 62, 220, PALETTE["olive"])
    columns = ["REST", "PRESSED", "DISABLED", "FOCUS / VOICEOVER"]
    values = [
        "Paper shadow 6 pt\nFull saturation",
        "Scale 0.985\nShadow 2 pt",
        "40% opacity\nNo shadow",
        "3 pt ink halo\nNamed action",
    ]
    x = 62
    for heading, value in zip(columns, values):
        c.setFont("Helvetica-Bold", 8)
        c.setFillColor(PALETTE["ink"])
        c.drawString(x, 190, heading)
        lines = value.split("\n")
        c.setFont("Helvetica", 8.5)
        c.setFillColor(PALETTE["ink_soft"])
        c.drawString(x, 166, lines[0])
        c.drawString(x, 152, lines[1])
        c.setStrokeColor(colors.Color(0.19, 0.17, 0.14, alpha=0.18))
        c.line(x + 160, 140, x + 160, 198)
        x += 180
    para(c, "Sensory feedback: light selection haptic for chips and sliders; medium impact only for turn completion; success haptic for match win. Respect Reduce Motion and Reduce Haptics settings.", 62, 122, 700, BODY_SMALL)
    c.showPage()


def application_page(c: Canvas, image_path: Path) -> None:
    page_base(c, 9, "Screen application")
    page_title(c, "Keep setup expressive; make gameplay quieter", "08 / Application", "The home screen can carry the full brand texture. Gameplay reduces decoration so timer, score, and the current word dominate.")
    draw_image_cover(c, image_path, 40, 74, 235, 390, 22)
    stages = [
        ("HOME", "Full paper system, logo, color-coded setup, one red CTA."),
        ("HANDOFF", "One paper card, player color, no decorative chips."),
        ("PLAYING", "Texture at 50%. Large word card. Timer and score use Ink, Olive, and Vermilion only."),
        ("RESULT", "Bring back colored outcome chips. Keep review rows orderly."),
        ("REVIEW", "Use the paper system, but prioritize density and scanning."),
    ]
    x, y = 315, 432
    accents = [PALETTE["mustard"], PALETTE["sky"], PALETTE["olive"], PALETTE["vermilion"], PALETTE["sage"]]
    for (name, desc), accent in zip(stages, accents):
        c.setFillColor(accent)
        c.roundRect(x, y - 12, 74, 28, 12, stroke=0, fill=1)
        c.setFillColor(PALETTE["ink"])
        c.setFont("Helvetica-Bold", 8)
        c.drawCentredString(x + 37, y - 2, name)
        para(c, desc, x + 94, y + 9, 370, BODY_SMALL)
        y -= 58
    paper_panel(c, 315, 74, 485, 80, 16)
    label(c, "Navigation", 336, 126, PALETTE["vermilion"])
    para(c, "Keep the existing Menu -> Handoff -> Ready -> Playing -> Result flow. The redesign changes presentation first; state transitions remain owned by AliasGameState.", 336, 110, 440, BODY_SMALL)
    c.showPage()


def implementation_page(c: Canvas) -> None:
    page_base(c, 10, "Implementation")
    page_title(c, "SwiftUI token map and release checklist", "09 / Implementation", "Centralize tokens in StudioTheme and StudioTypography, then build reusable paper surfaces before redesigning individual screens.")
    paper_panel(c, 40, 238, 355, 220, 22)
    label(c, "Token map", 62, 426, PALETTE["olive"])
    tokens = [
        ("canvas", "#F2E1C8"),
        ("paper", "#FFF3DE"),
        ("ink", "#211E19"),
        ("olive", "#5F7A2D"),
        ("mustard", "#F2B51D"),
        ("vermilion", "#D94A32"),
        ("sky", "#78AED0"),
        ("sage", "#9BAA58"),
    ]
    y = 396
    for name, value in tokens:
        c.setFillColor(hx(value))
        c.circle(72, y + 2, 6, stroke=0, fill=1)
        c.setFillColor(PALETTE["ink"])
        c.setFont("Courier-Bold", 8.5)
        c.drawString(88, y, f"StudioTheme.{name}")
        c.setFont("Courier", 8.5)
        c.drawRightString(368, y, value)
        y -= 23
    paper_panel(c, 420, 238, 380, 220, 22)
    label(c, "Build order", 442, 426, PALETTE["vermilion"])
    build_steps = [
        "1. Add palette and spacing tokens.",
        "2. Add one subtle seamless paper texture.",
        "3. Build PaperSurface, InkOutline, and PaperButtonStyle.",
        "4. Restyle mode selector, sliders, chips, and toggle.",
        "5. Apply home screen layout and validate both languages.",
        "6. Reduce texture for gameplay and results.",
    ]
    y = 394
    for step in build_steps:
        c.setFont("Helvetica", 9)
        c.setFillColor(PALETTE["ink"])
        c.drawString(444, y, step)
        y -= 27
    paper_panel(c, 40, 62, 760, 148, 22)
    label(c, "Definition of done", 62, 176, PALETTE["mustard"])
    checks = [
        "English and Ukrainian fit at largest Dynamic Type size.",
        "VoiceOver names every slider value and game action.",
        "Increase Contrast removes texture behind text.",
        "Reduce Motion disables paper-lift and card-swipe flourishes.",
        "All controls meet 44 x 44 pt and color is never the only state cue.",
        "Simulator build, stale-reference search, and git diff --check pass.",
    ]
    positions = [(62, 146), (420, 146), (62, 118), (420, 118), (62, 90), (420, 90)]
    for text, (x, y) in zip(checks, positions):
        c.setFillColor(PALETTE["olive"])
        c.circle(x + 5, y + 3, 5, stroke=0, fill=1)
        c.setStrokeColor(PALETTE["paper_high"])
        c.setLineWidth(1.2)
        c.line(x + 2, y + 3, x + 4, y + 1)
        c.line(x + 4, y + 1, x + 8, y + 6)
        para(c, text, x + 17, y + 12, 320, BODY_SMALL)
    c.showPage()


def build() -> Path:
    if not SOURCE_IMAGE.exists():
        raise FileNotFoundError(SOURCE_IMAGE)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    TMP.mkdir(parents=True, exist_ok=True)
    logo_crop = image_crop(SOURCE_IMAGE, "logo-crop.png", (115, 40, 780, 520))
    c = Canvas(str(OUTPUT), pagesize=(PAGE_W, PAGE_H), pageCompression=1)
    c.setTitle("YALIAS Visual Identity and UI Guide")
    c.setAuthor("YALIAS")
    c.setSubject("Brand and interface system for the YALIAS iOS game")
    cover(c, SOURCE_IMAGE)
    brand_core(c)
    logo_page(c, logo_crop)
    color_page(c)
    typography_page(c)
    materials_page(c)
    components_page(c)
    actions_states_page(c)
    application_page(c, SOURCE_IMAGE)
    implementation_page(c)
    c.save()
    return OUTPUT


if __name__ == "__main__":
    path = build()
    print(path)
