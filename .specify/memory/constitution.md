<!--
Sync Impact Report - Version 1.0.0 (Initial Creation)
======================================================
Version Change: N/A → 1.0.0
Created: 2025-11-17

Modified Principles:
- N/A (initial creation)

Added Sections:
- Language Requirements (Principle 1)
- Simplicity First (Principle 2)
- Test-Driven Development (Principle 3)
- Version Control Discipline (Principle 4)
- Documentation as Code (Principle 5)

Removed Sections:
- N/A

Templates Status:
✅ .specify/templates/plan-template.md - Created with language requirement notice
✅ .specify/templates/spec-template.md - Created with language requirement notice
✅ .specify/templates/tasks-template.md - Created with language requirement notice

Follow-up TODOs:
- None
======================================================
-->

# Project Constitution: Two-Stage Left Turn Map

**Constitution Version**: 1.0.0
**Ratification Date**: 2025-11-17
**Last Amended**: 2025-11-17

## Project Identity

**Project Name**: Two-Stage Left Turn Map

**Project Purpose**: A mapping and navigation solution for managing two-stage left turn intersections, providing clear guidance for drivers to safely navigate complex traffic scenarios.

**Core Mission**: Deliver a reliable, maintainable, and user-friendly system that enhances traffic safety through accurate mapping and intuitive guidance.

## Governing Principles

These principles are **non-negotiable** and form the foundation of all technical and process decisions within this project.

### Principle 1: Language Requirements

**Statement**: All project documentation, specifications, user stories, comments, and artifacts MUST be written in Traditional Chinese (繁體中文), with the SOLE exception of this Constitution document, which may be maintained in English for governance clarity.

**Rules**:
- Specification documents (spec.md, plan.md, research.md, etc.) MUST use Traditional Chinese
- Code comments MUST be in Traditional Chinese
- User stories and acceptance criteria MUST be in Traditional Chinese
- Task descriptions and documentation MUST be in Traditional Chinese
- Git commit messages SHOULD use Traditional Chinese where practical
- Only this constitution.md file is permitted to be in English

**Rationale**: This ensures consistency, accessibility, and clear communication for the primary stakeholder base while maintaining an English-language governance reference that aligns with international open-source standards.

**Validation**: Code reviews MUST reject pull requests containing documentation or comments not in Traditional Chinese (except constitution.md).

### Principle 2: Simplicity First

**Statement**: Every architectural decision MUST justify its complexity. Simple solutions are ALWAYS preferred unless a concrete, measurable benefit outweighs the added complexity.

**Rules**:
- Start with the simplest possible implementation
- No abstract base classes or interfaces until at least 3 concrete implementations exist
- No dependency injection frameworks unless managing 5+ cross-cutting concerns
- No microservices architecture unless system requires independent scaling of 3+ distinct domains
- No new libraries/frameworks without documented justification in plan.md

**Rationale**: Complexity is a liability. It increases cognitive load, maintenance burden, and onboarding time. The project optimizes for long-term maintainability over premature optimization.

**Validation**: All architecture decisions requiring complexity beyond a single-file solution MUST be documented in the "Complexity Tracking" section of plan.md with explicit justification.

### Principle 3: Test-Driven Development

**Statement**: Tests MUST be written before implementation code and MUST fail before implementation begins.

**Rules**:
- Write contract tests first (API behavior)
- Write integration tests second (user journeys)
- Implement code until tests pass
- Unit tests are OPTIONAL unless requested explicitly
- All tests MUST be runnable independently
- Test coverage metrics are advisory, not mandatory

**Rationale**: Tests define the contract and ensure implementation matches requirements. Writing tests first prevents implementation bias and ensures testability by design.

**Validation**: Pull requests MUST include evidence that tests were written first (e.g., separate commits showing failing tests before implementation).

### Principle 4: Version Control Discipline

**Statement**: Every commit MUST be atomic, meaningful, and revertible. Feature work MUST occur on dedicated branches following the naming convention `claude/[feature-description]-[session-id]`.

**Rules**:
- One logical change per commit
- Commit messages MUST follow conventional commits format: `type(scope): description`
- Feature branches MUST be created from main/master
- NO commits directly to main/master without pull request review
- NO force pushes to shared branches
- NO commits of secrets, credentials, or sensitive data

**Rationale**: Clean git history enables easy debugging, rollback, and understanding of project evolution. Branch discipline prevents conflicts and enables parallel development.

**Validation**: Pre-commit hooks MAY enforce commit message format. Pull requests with unclear history or merged conflicts MUST be rejected.

### Principle 5: Documentation as Code

**Statement**: Documentation MUST live alongside code, version-controlled, and updated atomically with implementation changes.

**Rules**:
- Specification documents in `.specify/` MUST be updated before implementation
- Quickstart guides MUST be executable and validated
- API contracts MUST be machine-readable (OpenAPI, JSON Schema, etc.)
- Changelog MUST be updated with every user-facing change
- NO documentation on external wikis or documents outside version control

**Rationale**: Out-of-sync documentation is worse than no documentation. Keeping docs in version control ensures they evolve with the codebase and enables review.

**Validation**: Pull requests that modify behavior MUST include corresponding documentation updates in the same PR.

## Governance

### Amendment Procedure

1. **Proposal**: Any team member may propose a constitution amendment via a dedicated markdown document in `.specify/proposals/`.
2. **Discussion**: Proposal MUST be discussed in a tracked issue or pull request with at least 3 business days for feedback.
3. **Approval**: Amendments require unanimous approval from all active maintainers.
4. **Versioning**: Upon approval, constitution version MUST be bumped according to semantic versioning (see below).
5. **Propagation**: All dependent templates and documentation MUST be updated to reflect the amendment.

### Versioning Policy

Constitution versions follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Backward-incompatible changes (removing principles, fundamentally redefining core governance)
- **MINOR**: Additive changes (new principles, expanded guidance, new mandatory sections)
- **PATCH**: Clarifications, typo fixes, wording improvements without semantic changes

### Compliance Review

- Constitution compliance MUST be checked at the beginning of every feature implementation (Phase 0 of plan.md)
- Violations MUST be explicitly documented and justified in the "Complexity Tracking" section
- Repeated violations of the same principle trigger a mandatory retrospective to assess whether the principle should be amended or better enforced

### Conflict Resolution

If a principle conflicts with a practical requirement:
1. Document the conflict in plan.md under "Constitution Check"
2. Propose a temporary exception with expiration date
3. If pattern repeats 3+ times, initiate amendment process to resolve systemic conflict

## Signature

This constitution represents the social contract for the **Two-Stage Left Turn Map** project. All contributors, by participating in this project, agree to uphold these principles.

**Ratified by**: Claude Code Agent
**Date**: 2025-11-17
**Authority**: Project Initialization
