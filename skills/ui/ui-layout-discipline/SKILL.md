---
name: ui-layout-discipline
description: Enforce disciplined UI layout implementation and review for SwiftUI, web UI, or other declarative UI work. Use when creating, refactoring, or fixing layouts with padding, spacing, margins, insets, frames, flex/grid/stack/list/form containers, ScrollView/List/GeometryReader, clipping, overflow, cards, rows, sidebars, inspectors, chat surfaces, or any symptom such as unexpected blank space, clipped content, stretched content, misalignment, nested wrappers, or fixed-size hacks.
---

# UI Layout Discipline

## Core Rule

Before editing UI layout code, build a space model. Do not fix layout symptoms by adding wrappers, padding, fixed sizes, measurement hacks, or competing modifiers.

Every visible gap, width, alignment, and clipping boundary must have one owner.

## Required Workflow

1. Trace the layout chain from the nearest stable parent to the broken element.
2. List each layer's job: available space, scroll, row/item sizing, alignment, visual chrome, and text/content layout.
3. Mark every `padding`, margin, inset, gap, spacing, frame, `Spacer`, `fixedSize`, overflow/clip, default component inset, and measurement tool.
4. Delete or bypass layers with no clear job before adding a new one.
5. Add the smallest constraint at the layer that owns the responsibility.
6. Verify that each visible gap and width comes from exactly one layer.

## Hard Bans

- Do not stack padding to repair layout. Padding expresses visual distance only.
- Do not add wrapper views just to "make it align" without naming their layout responsibility.
- Do not introduce fixed widths/heights unless they come from a design token, platform rule, business requirement, or parent-derived responsive formula.
- Do not use `GeometryReader`, DOM measurements, `calc(...)`, or manual viewport math before simpler parent/row/content ownership is clear.
- Do not mix opposite constraints in one chain, such as expand-to-fill plus fixed-size-to-content, spacer-push plus frame-align, or default list/form insets plus custom edge padding.
- Do not treat styled platform components as neutral containers; `List`, `Form`, `Section`, tables, form controls, buttons, and browser default elements may carry hidden insets, min sizes, clipping, and row wrappers.

## Padding Audit

For each new or existing padding/margin/inset, answer:

- Is it page/section spacing, item spacing, or content inner padding?
- Does another ancestor or descendant already own the same direction?
- Is it a design token/platform convention or an invented number?
- What exact visual relationship breaks if it is removed?

If the answer is unclear, remove it or move it to the layer that owns the spacing.

## Width And Alignment Audit

Separate these concerns:

- Parent/container: offers available space.
- Scroll/list viewport: clips or scrolls; it should not invent content width.
- Row/item: owns full-row occupation and cross-axis alignment.
- Visual surface: owns background, border, radius, and inner padding.
- Content/text: owns wrapping and intrinsic size.

Role-specific UI may need role-specific constraints. Shared styling does not imply shared layout. Examples: primary/secondary actions, sender/receiver messages, icon-only/text buttons, compact/expanded cards.

## Modifier Order Audit

Modifier order is layout semantics. Check especially:

- Width constraints must apply before background when the background should match wrapped content.
- Text must receive its wrapping width before clipping or background is evaluated.
- `fixedSize` must not be used on long or dynamic content unless overflow is intended.
- `frame(maxWidth: .infinity)` belongs on containers/rows, not on intrinsic visual surfaces unless the surface is supposed to fill.

## Debugging Symptoms

For unexpected blank space:
1. Inspect default component insets first.
2. Remove duplicate same-direction padding.
3. Check row wrappers and scroll/list viewport behavior.

For clipped content:
1. Find the first ancestor with fixed width, fixed height, clipping, or fixed-size content.
2. Move wrapping constraints before visual background/clip.
3. Remove invented fixed widths.

For stretched content:
1. Find `maxWidth: .infinity`, flex grow, grid stretch, or spacers applied to the visual surface.
2. Move fill behavior to the row/container.
3. Let the surface hug content or use a parent-derived max width.

## Completion Standard

Before calling a UI layout fix complete, state:

- Which layer owns available width.
- Which layer owns alignment.
- Which layer owns visual spacing.
- Which layer owns text wrapping.
- Why no visible spacing is duplicated.
- Why no fixed size is invented.
