## Context

The repository is expected to scale with heavy AI-assisted code generation. That increases throughput, but also increases the chance of oversized changes, invented domain fields, drift from shared contracts, and weak verification claims. The existing OpenSpec foundation is a good base, but it does not yet explicitly encode AI-specific workflow and guardrail expectations.

Constraints:
- The repository already uses OpenSpec and should keep using it as the main control plane.
- iOS is the only active implementation platform today, but the rules must work for future Android, Web, and backend work.
- The user expects explicit coding constraints such as SOLID decomposition, JS/TS file-size limits, and typed parameters.
- The adjustments should improve AI consistency without adding excessive ceremony to trivial configuration changes.

## Goals / Non-Goals

**Goals:**
- Encode repository-native rules for AI-generated changes.
- Make future OpenSpec artifacts inherit AI-friendly decomposition and verification expectations.
- Prevent AI from inventing domain semantics outside approved specs and shared contracts.
- Keep the rules lightweight enough to support fast iteration.

**Non-Goals:**
- Replace human review with process rules.
- Force every typo fix or tiny config edit through heavyweight ceremonies.
- Add AI-provider-specific tooling, SDKs, or prompt frameworks in this change.
- Introduce new runtime dependencies.

## Decisions

### 1. Use OpenSpec as the mandatory control plane for non-trivial AI work

Non-trivial AI-generated work must start from an OpenSpec change before implementation. This keeps planning, scope, and verification visible instead of letting the model improvise large multi-file edits.

Alternatives considered:
- Separate AI workflow docs outside OpenSpec: rejected because the repository already uses OpenSpec as its primary change system.
- Pure chat-based coordination: rejected because it does not persist constraints across future changes.

### 2. Store AI rules in `openspec/config.yaml` rather than only in ad hoc docs

OpenSpec artifact generation already reads project context and rules from `openspec/config.yaml`. Encoding the guardrails there makes them part of the default generation path instead of optional reading material.

Alternatives considered:
- README-only guidance: rejected because it is easier for automation to miss and does not directly shape artifact generation.

### 3. Keep source-of-truth boundaries explicit

The repository will treat `openspec/specs` and `shared/contracts` as the canonical definition of behavior and domain semantics. AI-generated code must implement those truths instead of redefining them in platform code.

Alternatives considered:
- Let platform code lead and backfill specs later: rejected because that creates contract drift and makes cross-platform alignment harder.

### 4. Make verification commands a first-class requirement

AI-generated tasks must include exact verification commands, and completion claims must be backed by fresh output. This reduces false confidence and makes AI iterations easier to review.

Alternatives considered:
- Require only general "run tests" language: rejected because it is too vague for reliable AI execution.

## Risks / Trade-offs

- [More process overhead for medium-sized changes] -> Mitigation: scope the rules to non-trivial work and keep config-only changes lighter.
- [AI may still overgenerate even with rules] -> Mitigation: reinforce change granularity, source-of-truth boundaries, and verification gates together.
- [Rules could become stale as the repo grows] -> Mitigation: evolve them through future OpenSpec changes instead of treating them as fixed forever.

## Migration Plan

1. Publish AI workflow capabilities in OpenSpec.
2. Update `openspec/config.yaml` with AI-specific context and artifact rules.
3. Update the root `README.md` so contributors can discover the workflow quickly.
4. Apply the new rules to subsequent implementation changes.

## Open Questions

- Whether the repository eventually needs provider-specific prompt packs or per-directory AI rules beyond OpenSpec context.
- Whether future generated-code-heavy areas need additional review tiers, such as mandatory code-owner review or automated diff classification.
