# LEARNINGS
- Word-count (or any composer) as `position: absolute; bottom: …` on the paper sheet pins to the *document* end. On a long page it sits on the last line, not the visible viewport. Use a flex column: scroll the writing, shrink-wrap the bar, pad the column with visualViewport keyboard height.
- Keyboard height is `innerHeight - visualViewport.height - visualViewport.offsetTop`, not `100dvh` and not safe-area-inset-bottom.
- Paper fibre/rules on a short library card stripe the preview. Compact sheets need a wash, not the full gutter + margin + multiply grain.
