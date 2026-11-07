"""Шаблони Ember Office (ODF: .ott / .otp / .ots) у кольорах поточної теми.
Створюються на льоту, тож документ одразу «в темі». Відкриваються LibreOffice як новий файл."""
import datetime
import zipfile
from xml.sax.saxutils import escape

NS = ('xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" '
      'xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" '
      'xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" '
      'xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" '
      'xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" '
      'xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" '
      'xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" '
      'xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" '
      'xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" '
      'xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" '
      'xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0" office:version="1.3"')

MIME = {"write": "application/vnd.oasis.opendocument.text-template",
        "slides": "application/vnd.oasis.opendocument.presentation-template",
        "sheets": "application/vnd.oasis.opendocument.spreadsheet-template"}
EXT = {"write": ".ott", "slides": ".otp", "sheets": ".ots"}

FONT = "Inter"


def _L(lang, uk, en, ru):
    return {"uk": uk, "en": en, "ru": ru}.get(lang, uk)


def _zip(path, kind, content, styles):
    manifest = ('<?xml version="1.0" encoding="UTF-8"?>\n'
                '<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.3">'
                f'<manifest:file-entry manifest:full-path="/" manifest:media-type="{MIME[kind]}"/>'
                '<manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>'
                '<manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>'
                '</manifest:manifest>')
    with zipfile.ZipFile(path, "w") as z:
        z.writestr(zipfile.ZipInfo("mimetype"), MIME[kind], compress_type=zipfile.ZIP_STORED)
        z.writestr("META-INF/manifest.xml", manifest, compress_type=zipfile.ZIP_DEFLATED)
        z.writestr("content.xml", content, compress_type=zipfile.ZIP_DEFLATED)
        z.writestr("styles.xml", styles, compress_type=zipfile.ZIP_DEFLATED)
    return path


FONTDECL = (f'<office:font-face-decls><style:font-face style:name="{FONT}" svg:font-family="{FONT}" '
            'style:font-family-generic="swiss"/></office:font-face-decls>')


# ───────────────────────── документ (Ember Write) ─────────────────────────

def _text_styles(t):
    a, a2 = t["accent"], t["accent2"]
    return (f'<?xml version="1.0" encoding="UTF-8"?>\n<office:document-styles {NS}>{FONTDECL}<office:styles>'
            f'<style:default-style style:family="paragraph"><style:paragraph-properties fo:margin-bottom="0.2cm" fo:line-height="130%"/>'
            f'<style:text-properties style:font-name="{FONT}" fo:font-size="11pt" fo:color="#222222" fo:language="uk"/></style:default-style>'
            '<style:style style:name="Standard" style:family="paragraph" style:class="text"/>'
            '<style:style style:name="Text_20_body" style:display-name="Text body" style:family="paragraph" style:parent-style-name="Standard"/>'
            f'<style:style style:name="Title" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:margin-bottom="0.15cm"/>'
            f'<style:text-properties fo:font-size="30pt" fo:font-weight="bold" fo:color="{a}"/></style:style>'
            f'<style:style style:name="Subtitle" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:margin-bottom="0.6cm"/>'
            f'<style:text-properties fo:font-size="13pt" fo:color="#777777"/></style:style>'
            f'<style:style style:name="Heading_20_1" style:display-name="Heading 1" style:family="paragraph" style:parent-style-name="Standard" style:default-outline-level="1">'
            f'<style:paragraph-properties fo:margin-top="0.5cm" fo:margin-bottom="0.2cm" fo:border-bottom="0.06pt solid {a2}" fo:padding-bottom="0.08cm"/>'
            f'<style:text-properties fo:font-size="17pt" fo:font-weight="bold" fo:color="{a}"/></style:style>'
            f'<style:style style:name="Heading_20_2" style:display-name="Heading 2" style:family="paragraph" style:parent-style-name="Standard" style:default-outline-level="2">'
            f'<style:paragraph-properties fo:margin-top="0.35cm" fo:margin-bottom="0.12cm"/>'
            f'<style:text-properties fo:font-size="13pt" fo:font-weight="bold" fo:color="{a2}"/></style:style>'
            '<style:style style:name="Muted" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:color="#888888" fo:font-size="10pt"/></style:style>'
            '<style:style style:name="Right" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:text-align="end"/></style:style>'
            '</office:styles><office:automatic-styles><style:page-layout style:name="pm1">'
            '<style:page-layout-properties fo:page-width="21cm" fo:page-height="29.7cm" fo:margin-top="2cm" fo:margin-bottom="2cm" fo:margin-left="2.2cm" fo:margin-right="2.2cm"/>'
            '</style:page-layout></office:automatic-styles><office:master-styles>'
            '<style:master-page style:name="Standard" style:page-layout-name="pm1"/></office:master-styles></office:document-styles>')


def _p(text, style="Standard"):
    return f'<text:p text:style-name="{style}">{escape(text)}</text:p>'


def _h(text, level=1):
    return f'<text:h text:style-name="Heading_20_{level}" text:outline-level="{level}">{escape(text)}</text:h>'


def _li(items):
    return "<text:list>" + "".join(f"<text:list-item>{_p(i)}</text:list-item>" for i in items) + "</text:list>"


def write_body(variant, lang):
    L = lambda *a: _L(lang, *a)  # noqa: E731
    today = datetime.date.today().strftime("%d.%m.%Y")
    if variant == "letter":
        return (_p(L("Ваше ім'я", "Your name", "Ваше имя"), "Title") + _p(L("Адреса · телефон · e-mail", "Address · phone · e-mail", "Адрес · телефон · e-mail"), "Subtitle")
                + _p(today, "Right") + _p("") + _p(L("Кому: …", "To: …", "Кому: …"))
                + _p("") + _p(L("Доброго дня!", "Hello,", "Здравствуйте!"))
                + _p(L("Текст листа…", "Letter text…", "Текст письма…")) + _p("")
                + _p(L("З повагою,", "Kind regards,", "С уважением,")) + _p(L("Ваше ім'я", "Your name", "Ваше имя")))
    if variant == "resume":
        return (_p(L("Ім'я Прізвище", "First Last", "Имя Фамилия"), "Title")
                + _p(L("Посада · місто · e-mail · телефон", "Role · city · e-mail · phone", "Должность · город · e-mail · телефон"), "Subtitle")
                + _h(L("Про мене", "About me", "Обо мне")) + _p(L("Кілька речень про себе…", "A few sentences about yourself…", "Пару предложений о себе…"))
                + _h(L("Досвід", "Experience", "Опыт")) + _h(L("Компанія — посада", "Company — role", "Компания — должность"), 2)
                + _p(L("2023 — зараз", "2023 — now", "2023 — сейчас"), "Muted") + _li([L("Що робив і чого досяг", "What you did and achieved", "Что делал и чего добился")])
                + _h(L("Освіта", "Education", "Образование")) + _p(L("Заклад, спеціальність, рік", "School, field, year", "Учебное заведение, специальность, год"))
                + _h(L("Навички", "Skills", "Навыки")) + _li([L("Навичка 1", "Skill 1", "Навык 1"), L("Навичка 2", "Skill 2", "Навык 2")]))
    if variant == "report":
        return (_p(L("Назва звіту", "Report title", "Название отчёта"), "Title") + _p(f"{L('Автор', 'Author', 'Автор')} · {today}", "Subtitle")
                + _h(L("Вступ", "Introduction", "Введение")) + _p(L("Про що цей звіт…", "What this report is about…", "О чём этот отчёт…"))
                + _h(L("Основна частина", "Main part", "Основная часть")) + _h(L("Підрозділ", "Subsection", "Подраздел"), 2) + _p("…")
                + _h(L("Висновки", "Conclusions", "Выводы")) + _li([L("Висновок 1", "Conclusion 1", "Вывод 1"), L("Висновок 2", "Conclusion 2", "Вывод 2")]))
    return _p("")


def make_write(path, variant, t, lang):
    content = (f'<?xml version="1.0" encoding="UTF-8"?>\n<office:document-content {NS}>{FONTDECL}'
               f'<office:body><office:text>{write_body(variant, lang)}</office:text></office:body></office:document-content>')
    return _zip(path, "write", content, _text_styles(t))


# ───────────────────────── презентація (Ember Slides) ─────────────────────────

def _slides_styles(t, variant):
    dark = variant != "light"
    bg = t["bg"] if dark else "#fbf7f2"
    fg = t["fg"] if dark else "#2a2230"
    a, a2 = t["accent"], t["accent2"]
    return (f'<?xml version="1.0" encoding="UTF-8"?>\n<office:document-styles {NS}>{FONTDECL}<office:styles>'
            f'<style:default-style style:family="graphic"><style:text-properties style:font-name="{FONT}" fo:color="{fg}"/></style:default-style>'
            '</office:styles><office:automatic-styles>'
            '<style:page-layout style:name="PM1"><style:page-layout-properties fo:margin-top="0cm" fo:margin-bottom="0cm" '
            'fo:margin-left="0cm" fo:margin-right="0cm" fo:page-width="28cm" fo:page-height="15.75cm" style:print-orientation="landscape"/></style:page-layout>'
            f'<style:style style:name="Mdp1" style:family="drawing-page"><style:drawing-page-properties draw:background-size="full" draw:fill="solid" draw:fill-color="{bg}"/></style:style>'
            f'<style:style style:name="MBar" style:family="graphic"><style:graphic-properties draw:stroke="none" draw:fill="solid" draw:fill-color="{a}"/></style:style>'
            '</office:automatic-styles><office:master-styles>'
            f'<style:master-page style:name="Ember" style:page-layout-name="PM1" draw:style-name="Mdp1">'
            '<draw:rect draw:style-name="MBar" draw:layer="backgroundobjects" svg:x="0cm" svg:y="15.35cm" svg:width="28cm" svg:height="0.4cm"/>'
            '</style:master-page></office:master-styles></office:document-styles>'), fg, a, a2


def make_slides(path, variant, t, lang):
    L = lambda *a: _L(lang, *a)  # noqa: E731
    styles, fg, a, a2 = _slides_styles(t, variant)
    auto = ('<office:automatic-styles>'
            f'<style:style style:name="gT" style:family="presentation"><style:graphic-properties draw:stroke="none" draw:fill="none" draw:textarea-vertical-align="bottom"/></style:style>'
            f'<style:style style:name="gB" style:family="presentation"><style:graphic-properties draw:stroke="none" draw:fill="none" draw:textarea-vertical-align="top"/></style:style>'
            f'<style:style style:name="pT" style:family="paragraph"><style:text-properties fo:font-size="44pt" fo:font-weight="bold" fo:color="{a}" style:font-name="{FONT}"/></style:style>'
            f'<style:style style:name="pS" style:family="paragraph"><style:text-properties fo:font-size="22pt" fo:color="{fg}" style:font-name="{FONT}"/></style:style>'
            f'<style:style style:name="pH" style:family="paragraph"><style:text-properties fo:font-size="32pt" fo:font-weight="bold" fo:color="{a}" style:font-name="{FONT}"/></style:style>'
            f'<style:style style:name="pB" style:family="paragraph"><style:paragraph-properties fo:margin-bottom="0.3cm"/><style:text-properties fo:font-size="22pt" fo:color="{fg}" style:font-name="{FONT}"/></style:style>'
            f'<style:style style:name="pD" style:family="paragraph"><style:text-properties fo:font-size="22pt" fo:color="{a2}" style:font-name="{FONT}"/></style:style>'
            '</office:automatic-styles>')

    def frame(cls, gstyle, x, y, w, h, paras):
        body = "".join(f'<text:p text:style-name="{s}">{escape(tx)}</text:p>' for s, tx in paras)
        return (f'<draw:frame presentation:style-name="{gstyle}" draw:layer="layout" svg:x="{x}cm" svg:y="{y}cm" svg:width="{w}cm" '
                f'svg:height="{h}cm" presentation:class="{cls}" presentation:user-transformed="true"><draw:text-box>{body}</draw:text-box></draw:frame>')

    s1 = (f'<draw:page draw:name="1" draw:master-page-name="Ember">'
          + frame("title", "gT", 2.2, 3.2, 23.6, 5.2, [("pT", L("Назва презентації", "Presentation title", "Название презентации"))])
          + frame("subtitle", "gB", 2.2, 8.8, 23.6, 3, [("pS", L("Підзаголовок · ваше ім'я", "Subtitle · your name", "Подзаголовок · ваше имя"))])
          + '</draw:page>')
    s2 = (f'<draw:page draw:name="2" draw:master-page-name="Ember">'
          + frame("title", "gT", 2.2, 1.0, 23.6, 2.6, [("pH", L("Заголовок слайда", "Slide title", "Заголовок слайда"))])
          + frame("outline", "gB", 2.2, 4.2, 23.6, 10, [("pB", "• " + L("Перша думка", "First point", "Первая мысль")),
                                                         ("pB", "• " + L("Друга думка", "Second point", "Вторая мысль")),
                                                         ("pD", "• " + L("Головне — кольором теми", "Key point — in the theme colour", "Главное — цветом темы"))])
          + '</draw:page>')
    content = (f'<?xml version="1.0" encoding="UTF-8"?>\n<office:document-content {NS}>{FONTDECL}{auto}'
               f'<office:body><office:presentation>{s1}{s2}</office:presentation></office:body></office:document-content>')
    return _zip(path, "slides", content, styles)


# ───────────────────────── таблиця (Ember Sheets) ─────────────────────────

def make_sheets(path, variant, t, lang):
    L = lambda *a: _L(lang, *a)  # noqa: E731
    a = t["accent"]
    auto = ('<office:automatic-styles>'
            '<style:style style:name="co1" style:family="table-column"><style:table-column-properties style:column-width="5.5cm"/></style:style>'
            '<style:style style:name="co2" style:family="table-column"><style:table-column-properties style:column-width="3.2cm"/></style:style>'
            f'<style:style style:name="hd" style:family="table-cell"><style:table-cell-properties fo:background-color="{a}" fo:padding="0.1cm"/>'
            f'<style:text-properties fo:color="#ffffff" fo:font-weight="bold" style:font-name="{FONT}"/></style:style>'
            f'<style:style style:name="tt" style:family="table-cell"><style:table-cell-properties fo:border-top="1.2pt solid {a}"/>'
            f'<style:text-properties fo:font-weight="bold" fo:color="{a}" style:font-name="{FONT}"/></style:style>'
            f'<style:style style:name="ti" style:family="table-cell"><style:text-properties fo:font-size="18pt" fo:font-weight="bold" fo:color="{a}" style:font-name="{FONT}"/></style:style>'
            '</office:automatic-styles>')

    def cell(v, style=None, formula=None):
        st = f' table:style-name="{style}"' if style else ""
        if formula:
            return f'<table:table-cell{st} table:formula="of:={formula}" office:value-type="float" office:value="0"><text:p/></table:table-cell>'
        if isinstance(v, (int, float)):
            return f'<table:table-cell{st} office:value-type="float" office:value="{v}"><text:p>{v}</text:p></table:table-cell>'
        return f'<table:table-cell{st} office:value-type="string"><text:p>{escape(str(v))}</text:p></table:table-cell>'

    rows = []
    if variant == "budget":
        rows.append(cell(L("Бюджет", "Budget", "Бюджет"), "ti"))
        rows.append("")
        rows.append(cell(L("Стаття", "Item", "Статья"), "hd") + cell(L("План", "Plan", "План"), "hd") + cell(L("Факт", "Actual", "Факт"), "hd") + cell(L("Різниця", "Difference", "Разница"), "hd"))
        items = [(L("Житло", "Housing", "Жильё"), 8000, 8000), (L("Їжа", "Food", "Еда"), 5000, 5600),
                 (L("Транспорт", "Transport", "Транспорт"), 1200, 900), (L("Ігри та розваги", "Games & fun", "Игры и развлечения"), 1000, 1500),
                 (L("Інше", "Other", "Другое"), 1500, 700)]
        for i, (n, p, f) in enumerate(items):
            r = 4 + i
            rows.append(cell(n) + cell(p) + cell(f) + cell(None, formula=f"[.B{r}]-[.C{r}]"))
        last = 3 + len(items)
        rows.append(cell(L("Разом", "Total", "Итого"), "tt") + cell(None, "tt", f"SUM([.B4:.B{last}])")
                    + cell(None, "tt", f"SUM([.C4:.C{last}])") + cell(None, "tt", f"[.B{last + 1}]-[.C{last + 1}]"))
    else:
        rows.append(cell("A", "hd") + cell("B", "hd") + cell("C", "hd") + cell("D", "hd"))
    body = "".join(f"<table:table-row>{r}</table:table-row>" for r in rows)
    content = (f'<?xml version="1.0" encoding="UTF-8"?>\n<office:document-content {NS}>{FONTDECL}{auto}'
               f'<office:body><office:spreadsheet><table:table table:name="{escape(L("Аркуш1", "Sheet1", "Лист1"))}">'
               '<table:table-column table:style-name="co1"/><table:table-column table:style-name="co2" table:number-columns-repeated="3"/>'
               f'{body}</table:table></office:spreadsheet></office:body></office:document-content>')
    styles = (f'<?xml version="1.0" encoding="UTF-8"?>\n<office:document-styles {NS}>{FONTDECL}<office:styles>'
              f'<style:default-style style:family="table-cell"><style:text-properties style:font-name="{FONT}" fo:font-size="11pt"/></style:default-style>'
              '</office:styles></office:document-styles>')
    return _zip(path, "sheets", content, styles)


VARIANTS = {"write": ["blank", "letter", "resume", "report"], "slides": ["dark", "light"], "sheets": ["blank", "budget"]}


def make(kind, variant, t, lang, path):
    return {"write": make_write, "slides": make_slides, "sheets": make_sheets}[kind](path, variant, t, lang)
