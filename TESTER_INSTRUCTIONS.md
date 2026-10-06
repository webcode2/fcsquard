# Random Team Shuffle — Tester Instructions (v1.0)

Thank you for testing **Random Team Shuffle** (`com.ecslab.fcsquad`). This app helps you manage a football squad, generate balanced teams for a match, and track player stats over time. All data stays on your device — no account or internet required for core features.

**Time needed:** ~20–30 minutes  
**Report issues to:** [add your email or feedback channel]

---

## Before you start

- Install the build from the **closed testing** link you were sent (Play Store) or TestFlight (iOS).
- Use a real phone if possible (not only an emulator).
- Note your device model and Android/iOS version when reporting bugs.

---

## 1. MY SQUAD tab

- [ ] Add a new player (name, jersey number, position: DEF / MID / FWD).
- [ ] Edit an existing player (change name, number, or position).
- [ ] Delete a single player — confirm the confirmation dialog appears.
- [ ] Search for a player by name.
- [ ] Filter the list with ALL / DEF / MID / FWD chips.
- [ ] Tap **Clear squad** — confirm it warns that history/stats are **not** deleted.
- [ ] Leave and return to the tab — players should still be there.

---

## 2. GENERATE tab

- [ ] Paste a list of names (with numbers or bullets, e.g. `1. Alex`) and confirm names are parsed correctly.
- [ ] Change **number of teams** (2–8) with + / −.
- [ ] Tap **Assign roles** / **Generate teams** and continue to role selection.
- [ ] Open **Match history** from the clock icon — list loads (empty or with past matches).

**Also try without pasting:** with players already in MY SQUAD, generate teams from the saved roster.

---

## 3. Assign roles & generate teams

- [ ] Set each player’s position (DEF / MID / FWD).
- [ ] Try **AUTO** vs assigning a fixed team (TEAM 1, TEAM 2, …).
- [ ] Generate with a **balanced** squad (equal DEF/MID/FWD counts per team).
- [ ] Generate with an **unbalanced** squad — confirm the “position imbalance” warning appears and **Generate anyway** still works.
- [ ] After success, you should land on the **Match formation** screen with colored team cards.

---

## 4. Match formation & share

- [ ] All players appear on the correct teams, sorted by position.
- [ ] Tap **Share** — system share sheet opens with readable team text.
- [ ] Send share to Messages/WhatsApp (or cancel) — no crash.
- [ ] Go back — generated squad should be saved under MY SQUAD.

---

## 5. Match history

- [ ] From GENERATE → history icon: past matches are listed with date and team count.
- [ ] Tap a match — opens the same formation view as when it was generated.
- [ ] Swipe to **delete** a match — confirm dialog, then it disappears.

---

## 6. STATS tab (Vault records)

- [ ] After generating teams, check if relevant names appear (stats may be empty on first use).
- [ ] **Add** a manual stat entry (name, goals, assists, clean sheets).
- [ ] **Update** an existing player’s stats with the steppers.
- [ ] Swipe to **delete** a stat record.
- [ ] Confirm sorting (highest goals first).

---

## 7. General / stability

- [ ] Switch between all three tabs repeatedly — no blank screens or freezes.
- [ ] Rotate the device (if rotation is enabled) — layout should remain usable.
- [ ] Force-close the app and reopen — squad, history, and stats should persist.
- [ ] Use with **10+ players** and **4+ teams** if you can — check performance and readability.

---

## What to report

Please include:

1. **What you did** (steps to reproduce)  
2. **What you expected** vs **what happened**  
3. **Device** (e.g. Pixel 8, Android 14 / iPhone 13, iOS 17)  
4. **Screenshots or screen recording** if possible  

**Especially flag:** crashes, wrong team splits, lost data after restart, share not working, typos, or buttons that do nothing.

---

## Out of scope for this test

- No login, cloud sync, or online multiplayer — by design.
- No camera, contacts, or location permissions — the app should not ask for them.
