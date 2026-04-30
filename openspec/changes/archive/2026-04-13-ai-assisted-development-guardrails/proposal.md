## Why

The project will rely heavily on AI-assisted code generation, which makes speed easy but inconsistency and architectural drift much more likely. We need repository-native guardrails now so future AI-generated changes stay small, spec-driven, boundary-aware, and verifiable.

## What Changes

- Add formal OpenSpec capabilities that define how non-trivial AI-generated changes must be scoped and driven.
- Define source-of-truth and boundary rules for AI-generated code so models do not invent fields, contracts, or cross-platform abstractions outside approved specs.
- Define verification gates for AI-generated code changes, including exact verification commands and test expectations.
- Update `openspec/config.yaml` so future artifact generation automatically inherits these AI-focused conventions.
- Update the root `README.md` with a concise AI development workflow summary.

## Capabilities

### New Capabilities

- `ai-change-workflow`: Define how AI-generated work must be decomposed into OpenSpec-driven, independently verifiable changes.
- `ai-code-generation-boundaries`: Define source-of-truth and repository-boundary rules for AI-generated code.
- `ai-verification-gates`: Define verification expectations before AI-generated work is considered complete.

### Modified Capabilities

## Impact

- Affects future OpenSpec proposals, designs, and tasks across the repository.
- Affects repository-level AI collaboration behavior through `openspec/config.yaml` and `README.md`.
- Reduces the risk of large AI-generated changes bypassing specs, contracts, or verification.
