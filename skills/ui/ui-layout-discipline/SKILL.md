---
name: ui-layout-discipline
description: Proactively audit the affected layout chain when creating, adjusting, or fixing UI layout, including dimensions, spacing, alignment, wrapping, clipping, and scrolling. For other UI changes, trigger only when the user explicitly requests a layout audit.
---

# UI Layout Audit

## Trigger scope

Run this workflow proactively for layout changes. Do not automatically audit changes limited to wording, colors, icons, business logic, or persistence when layout behavior is unchanged. When the user requests an audit, inspect the specified scope. Treat wording or similar changes as layout changes if they actually affect wrapping, dimensions, or overflow.

## Locate and modify

1. Trace from the nearest stable parent container to the affected element. Identify which layer owns available space, scrolling, row dimensions, alignment, visual surfaces, and text.
2. Inspect padding, margin, inset, spacing, frame, Spacer, fixedSize, clipping, and default component insets along that chain to find the constraint causing the issue.
3. Change the smallest constraint at the layer responsible for the relationship. Remove confirmed redundant constraints; do not remove existing layout simply because it is not yet understood.
4. Check relevant scenarios such as target dimensions, long text, window resizing, and state changes. Follow user and project authorization requirements for UI verification tools.

## Evaluate constraints

- Distinguish page spacing, element spacing, and surface insets. Avoid adding padding twice for the same visual relationship; combine layers when they express different distances.
- Explain the layout responsibility of any new wrapper. Do not hide misalignment behind purposeless nesting.
- Derive fixed dimensions from design requirements, platform conventions, existing tokens, or explicit responsive calculations. Do not hide constraint problems with trial-and-error numbers.
- Before using measurement tools, inspect the space offered by the parent and the default behavior of system controls. When measurement is necessary, explain what the calculation depends on.
- In SwiftUI, check modifier order: establish content width before a background that follows the content, and distinguish row fill space from surface content dimensions. For web layouts, inspect the corresponding box model and flex/grid constraints; do not apply SwiftUI modifier rules.

## Report and finish

Report the actual layout cause, edit locations, and completed validation. Include only conclusions relevant to this issue; do not always return the entire audit checklist. Stop when existing validation covers the changes, without expanding the audit for formality.
