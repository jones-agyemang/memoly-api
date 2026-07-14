# Linear issue templates

Create these as **standard issue templates** under **Team settings → Templates** for the **Memoly** team.

When editing a template in Linear, select the instructional text in square brackets and apply Linear's **Placeholder** style from the `Aa` formatting menu. This makes the guidance disappear when the author starts typing.

Unless a template says otherwise, use these default properties:

- Team: `Memoly`
- Status: `Backlog`
- Priority: No priority
- Assignee: Unassigned
- Project: None

## Feature story

**Template name:** Feature story

**Template description:** Propose a new user-facing capability or workflow.

**Issue title:** `[Feature] [Short outcome]`

**Label:** `Feature`

**Issue description:**

```markdown
## User story

As a [type of user], I want [capability] so that [benefit].

## Context

[What user need, pain point, or opportunity prompted this request?]

## Acceptance criteria

- [ ] Given [context], when [action], then [observable result]
- [ ] Given [context], when [action], then [observable result]

## Scope

### In scope

- [What this story includes]

### Out of scope

- [What this story explicitly excludes]

## Supporting material

[Add mock-ups, examples, analytics, related issues, or technical notes.]
```

## Bug report

**Template name:** Bug report

**Template description:** Report broken, incorrect, or unexpected behaviour with enough detail to reproduce it.

**Issue title:** `[Bug] [Short description of the problem]`

**Label:** `Bug`

**Issue description:**

```markdown
## Problem

As a [type of user], I cannot [expected action], which means [impact].

## Steps to reproduce

1. [First step]
2. [Second step]
3. [Observe the problem]

## Expected behaviour

[What should happen?]

## Actual behaviour

[What happens instead? Include the exact error message when useful.]

## Environment

- Environment: [Production, staging, or development]
- Client/version: [Browser, device, app version, or API version]
- Relevant state: [Account, permissions, request, or record state]

## Severity

[Critical: service unavailable, data loss, or security impact / High: core workflow blocked / Medium: degraded with a workaround / Low: minor or cosmetic]

## Acceptance criteria

- [ ] The reported scenario produces the expected result
- [ ] Relevant regression coverage is added
- [ ] Related workflows continue to work

## Evidence

[Add logs, screenshots, request IDs, or sample payloads. Remove secrets and personal data.]
```

## Improvement story

**Template name:** Improvement story

**Template description:** Improve an existing capability, workflow, or quality attribute.

**Issue title:** `[Improvement] [Short outcome]`

**Label:** `Improvement`

**Issue description:**

```markdown
## User story

As a [type of user], I want [existing capability] to be [better outcome] so that [benefit].

## Current experience

[How does it work today, and where does it fall short?]

## Desired outcome

[Describe the improved experience without prescribing an implementation unless necessary.]

## Evidence and success measure

[What data, feedback, benchmark, or observation supports this? How will improvement be measured?]

## Acceptance criteria

- [ ] Given [context], when [action], then [observable result]
- [ ] Existing behaviour remains compatible where required
- [ ] The agreed success measure is met

## Constraints and dependencies

[Note compatibility requirements, dependencies, risks, or boundaries.]
```

## Design story

**Template name:** Design story

**Template description:** Request UX, UI, service, content, or interaction design work.

**Issue title:** `[Design] [Experience or flow to design]`

**Label:** Create and select `Design`; no matching label currently exists.

**Issue description:**

```markdown
## Design challenge

As a [type of user], I need [experience or information] so that [benefit].

## Users and context

[Who is this for, and in what situation will they encounter it?]

## Scope and deliverables

[Define the flows, screens, content, research, prototype, or hand-off expected.]

## States and edge cases

- [ ] Loading
- [ ] Empty
- [ ] Error
- [ ] Success
- [ ] Permissions
- [ ] Responsive behaviour
- [ ] Unusual or long content

## Constraints

[Note design-system, brand, technical, legal, accessibility, localisation, or deadline constraints.]

## Acceptance criteria

- [ ] The agreed flows and states are covered
- [ ] Accessibility requirements are documented
- [ ] Responsive behaviour is defined where relevant
- [ ] The design is reviewed with the relevant stakeholders

## References

[Add research, screenshots, comparable experiences, analytics, or related issues.]
```

## Technical debt story

**Template name:** Technical debt

**Template description:** Address maintainability, reliability, security, or engineering health.

**Issue title:** `[Tech debt] [Short technical outcome]`

**Label:** Create and select `Technical debt`; no matching label currently exists.

**Issue description:**

```markdown
## Engineering problem

[What is difficult, risky, costly, or fragile today?]

## Impact

[What is the effect on users, delivery speed, operations, cost, security, or reliability?]

## Desired outcome

We want [technical outcome] so that [measurable engineering or user benefit].

## Proposed approach

[Outline a likely solution, migration path, and alternatives considered. This may change during implementation.]

## Acceptance criteria

- [ ] The target risk or maintenance burden is removed
- [ ] Behaviour remains unchanged unless explicitly stated
- [ ] Tests, monitoring, and documentation are updated as needed
- [ ] Rollback or migration concerns are addressed

## Risks and dependencies

[Note migration, compatibility, rollout, ownership, or sequencing concerns.]
```

## Research or spike

**Template name:** Research or spike

**Template description:** Time-box discovery when the solution, feasibility, or estimate is uncertain.

**Issue title:** `[Spike] [Question to answer]`

**Label:** Create and select `Spike`; no matching label currently exists.

**Issue description:**

```markdown
## Question to answer

[What decision or uncertainty must this investigation resolve?]

## Context

[Why is the answer needed, and what work will it unblock?]

## Time-box

[For example, one day or three engineering days.]

## Investigation scope

### Explore

- [What will be investigated]

### Do not explore

- [What is outside this spike]

## Expected output

- [ ] Findings and evidence are documented
- [ ] Options and trade-offs are compared
- [ ] A recommendation is made
- [ ] Follow-up stories are created or updated

## References

[Add relevant code, documentation, incidents, prior art, or related issues.]
```
