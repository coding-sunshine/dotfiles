# Feature list — input for `autobuild`

List what the software should do, one feature per bullet. Keep each feature
small and independently testable — `autobuild` turns these into an ordered
Ralph `prd.json` backlog, then builds them test-first, unattended.

Be specific about behaviour and acceptance criteria; vague features produce
vague stories. State the stack if you care which one (else the planner picks).

## Example — replace everything below

Stack: Laravel (API) + Pest tests.

- Health-check endpoint `GET /up` returns 200 with `{"status":"ok"}`.
- User model + migration (name, email unique, password hash).
- Signup `POST /register` with validation; returns 201 + token; tests cover
  duplicate email and weak password.
- Login `POST /login` issues a token; wrong password returns 401; tests cover both.
- Authenticated `GET /me` returns the current user; 401 when no/invalid token.
