/* hint.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <string.h>
#include <stdio.h>
#include <stdbool.h>

#include <ruby.h>

#include "sax_hint.h"

static const char	*audio_video_0[] = { "audio", "video", 0 };
static const char	*colgroup_0[] = { "colgroup", 0 };
static const char	*details_0[] = { "details", 0 };
static const char	*dl_0[] = { "dl", 0 };
static const char	*dt_th_0[] = { "dt", "th", 0 };
static const char	*fieldset_0[] = { "fieldset", 0 };
static const char	*figure_0[] = { "figure", 0 };
static const char	*frameset_0[] = { "frameset", 0 };
static const char	*head_0[] = { "head", 0 };
static const char	*html_0[] = { "html", 0 };
static const char	*map_0[] = { "map", 0 };
static const char	*ol_ul_menu_0[] = { "ol", "ul", "menu", 0 };
static const char	*optgroup_select_datalist_0[] = { "optgroup", "select", "datalist", 0 };
static const char	*ruby_0[] = { "ruby", 0 };
static const char	*table_0[] = { "table", 0 };
static const char	*tr_0[] = { "tr", 0 };

static struct _Hint	html_hint_array[] = {
    { "!--", false, false, false, ActiveOverlay, NULL }, // comment
    { "a", false, false, false, ActiveOverlay, NULL },
    { "abbr", false, false, false, ActiveOverlay, NULL },
    { "acronym", false, false, false, ActiveOverlay, NULL },
    { "address", false, false, false, ActiveOverlay, NULL },
    { "applet", false, false, false, ActiveOverlay, NULL },
    { "area", true, false, false, ActiveOverlay, map_0 },
    { "article", false, false, false, ActiveOverlay, NULL },
    { "aside", false, false, false, ActiveOverlay, NULL },
    { "audio", false, false, false, ActiveOverlay, NULL },
    { "b", false, false, false, ActiveOverlay, NULL },
    { "base", true, false, false, ActiveOverlay, head_0 },
    { "basefont", true, false, false, ActiveOverlay, head_0 },
    { "bdi", false, false, false, ActiveOverlay, NULL },
    { "bdo", false, true, false, ActiveOverlay, NULL },
    { "big", false, false, false, ActiveOverlay, NULL },
    { "blockquote", false, false, false, ActiveOverlay, NULL },
    { "body", false, false, false, ActiveOverlay, html_0 },
    { "br", true, false, false, ActiveOverlay, NULL },
    { "button", false, false, false, ActiveOverlay, NULL },
    { "canvas", false, false, false, ActiveOverlay, NULL },
    { "caption", false, false, false, ActiveOverlay, table_0 },
    { "center", false, false, false, ActiveOverlay, NULL },
    { "cite", false, false, false, ActiveOverlay, NULL },
    { "code", false, false, false, ActiveOverlay, NULL },
    { "col", true, false, false, ActiveOverlay, colgroup_0 },
    { "colgroup", false, false, false, ActiveOverlay, NULL },
    { "command", true, false, false, ActiveOverlay, NULL },
    { "datalist", false, false, false, ActiveOverlay, NULL },
    { "dd", false, false, false, ActiveOverlay, dl_0 },
    { "del", false, false, false, ActiveOverlay, NULL },
    { "details", false, false, false, ActiveOverlay, NULL },
    { "dfn", false, false, false, ActiveOverlay, NULL },
    { "dialog", false, false, false, ActiveOverlay, dt_th_0 },
    { "dir", false, false, false, ActiveOverlay, NULL },
    { "div", false, true, false, ActiveOverlay, NULL },
    { "dl", false, false, false, ActiveOverlay, NULL },
    { "dt", false, true, false, ActiveOverlay, dl_0 },
    { "em", false, false, false, ActiveOverlay, NULL },
    { "embed", true, false, false, ActiveOverlay, NULL },
    { "fieldset", false, false, false, ActiveOverlay, NULL },
    { "figcaption", false, false, false, ActiveOverlay, figure_0 },
    { "figure", false, false, false, ActiveOverlay, NULL },
    { "font", false, true, false, ActiveOverlay, NULL },
    { "footer", false, false, false, ActiveOverlay, NULL },
    { "form", false, false, false, ActiveOverlay, NULL },
    { "frame", true, false, false, ActiveOverlay, frameset_0 },
    { "frameset", false, false, false, ActiveOverlay, NULL },
    { "h1", false, false, false, ActiveOverlay, NULL },
    { "h2", false, false, false, ActiveOverlay, NULL },
    { "h3", false, false, false, ActiveOverlay, NULL },
    { "h4", false, false, false, ActiveOverlay, NULL },
    { "h5", false, false, false, ActiveOverlay, NULL },
    { "h6", false, false, false, ActiveOverlay, NULL },
    { "head", false, false, false, ActiveOverlay, html_0 },
    { "header", false, false, false, ActiveOverlay, NULL },
    { "hgroup", false, false, false, ActiveOverlay, NULL },
    { "hr", true, false, false, ActiveOverlay, NULL },
    { "html", false, false, false, ActiveOverlay, NULL },
    { "i", false, false, false, ActiveOverlay, NULL },
    { "iframe", true, false, false, ActiveOverlay, NULL },
    { "img", true, false, false, ActiveOverlay, NULL },
    { "input", true, false, false, ActiveOverlay, NULL }, // somewhere under a form_0
    { "ins", false, false, false, ActiveOverlay, NULL },
    { "kbd", false, false, false, ActiveOverlay, NULL },
    { "keygen", true, false, false, ActiveOverlay, NULL },
    { "label", false, false, false, ActiveOverlay, NULL }, // somewhere under a form_0
    { "legend", false, false, false, ActiveOverlay, fieldset_0 },
    { "li", false, false, false, ActiveOverlay, ol_ul_menu_0 },
    { "link", true, false, false, ActiveOverlay, head_0 },
    { "map", false, false, false, ActiveOverlay, NULL },
    { "mark", false, false, false, ActiveOverlay, NULL },
    { "menu", false, false, false, ActiveOverlay, NULL },
    { "meta", true, false, false, ActiveOverlay, head_0 },
    { "meter", false, false, false, ActiveOverlay, NULL },
    { "nav", false, false, false, ActiveOverlay, NULL },
    { "noframes", false, false, false, ActiveOverlay, NULL },
    { "noscript", false, false, false, ActiveOverlay, NULL },
    { "object", false, false, false, ActiveOverlay, NULL },
    { "ol", false, true, false, ActiveOverlay, NULL },
    { "optgroup", false, false, false, ActiveOverlay, NULL },
    { "option", false, false, false, ActiveOverlay, optgroup_select_datalist_0 },
    { "output", false, false, false, ActiveOverlay, NULL },
    { "p", false, false, false, ActiveOverlay, NULL },
    { "param", true, false, false, ActiveOverlay, NULL },
    { "pre", false, false, false, ActiveOverlay, NULL },
    { "progress", false, false, false, ActiveOverlay, NULL },
    { "q", false, false, false, ActiveOverlay, NULL },
    { "rp", false, false, false, ActiveOverlay, ruby_0 },
    { "rt", false, false, false, ActiveOverlay, ruby_0 },
    { "ruby", false, false, false, ActiveOverlay, NULL },
    { "s", false, false, false, ActiveOverlay, NULL },
    { "samp", false, false, false, ActiveOverlay, NULL },
    { "script", false, false, true, ActiveOverlay, NULL },
    { "section", false, true, false, ActiveOverlay, NULL },
    { "select", false, false, false, ActiveOverlay, NULL },
    { "small", false, false, false, ActiveOverlay, NULL },
    { "source", false, false, false, ActiveOverlay, audio_video_0 },
    { "span", false, true, false, ActiveOverlay, NULL },
    { "strike", false, false, false, ActiveOverlay, NULL },
    { "strong", false, false, false, ActiveOverlay, NULL },
    { "style", false, false, false, ActiveOverlay, NULL },
    { "sub", false, false, false, ActiveOverlay, NULL },
    { "summary", false, false, false, ActiveOverlay, details_0 },
    { "sup", false, false, false, ActiveOverlay, NULL },
    { "table", false, false, false, ActiveOverlay, NULL },
    { "tbody", false, false, false, ActiveOverlay, table_0 },
    { "td", false, false, false, ActiveOverlay, tr_0 },
    { "textarea", false, false, false, ActiveOverlay, NULL },
    { "tfoot", false, false, false, ActiveOverlay, table_0 },
    { "th", false, false, false, ActiveOverlay, tr_0 },
    { "thead", false, false, false, ActiveOverlay, table_0 },
    { "time", false, false, false, ActiveOverlay, NULL },
    { "title", false, false, false, ActiveOverlay, head_0 },
    { "tr", false, false, false, ActiveOverlay, table_0 },
    { "track", true, false, false, ActiveOverlay, audio_video_0 },
    { "tt", false, false, false, ActiveOverlay, NULL },
    { "u", false, false, false, ActiveOverlay, NULL },
    { "ul", false, false, false, ActiveOverlay, NULL },
    { "var", false, false, false, ActiveOverlay, NULL },
    { "video", false, false, false, ActiveOverlay, NULL },
    { "wbr", true, false, false, ActiveOverlay, NULL },
};
static struct _Hints	html_hints = {
    "HTML",
    html_hint_array,
    sizeof(html_hint_array) / sizeof(*html_hint_array)
};

Hints
ox_hints_html() {
    return &html_hints;
}

Hints
ox_hints_dup(Hints h) {
    Hints	nh = ALLOC(struct _Hints);

    nh->hints = ALLOC_N(struct _Hint, h->size);
    memcpy(nh->hints, h->hints, sizeof(struct _Hint) * h->size);
    nh->size = h->size;
    nh->name = h->name;
    
    return nh;
}

void
ox_hints_destroy(Hints h) {
    if (NULL != h && &html_hints != h) {
	xfree(h->hints);
	xfree(h);
    }
}

Hint
ox_hint_find(Hints hints, const char *name) {
    if (0 != hints) {
	Hint	lo = hints->hints;
	Hint	hi = hints->hints + hints->size - 1;
	Hint	mid;
	int		res;

	if (0 == (res = strcasecmp(name, lo->name))) {
	    return lo;
	} else if (0 > res) {
	    return 0;
	}
	if (0 == (res = strcasecmp(name, hi->name))) {
	    return hi;
	} else if (0 < res) {
	    return 0;
	}
	while (1 < hi - lo) {
	    mid = lo + (hi - lo) / 2;
	    if (0 == (res = strcasecmp(name, mid->name))) {
		return mid;
	    } else if (0 < res) {
		lo = mid;
	    } else {
		hi = mid;
	    }
	}
    }
    return 0;
}
