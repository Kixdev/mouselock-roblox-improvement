# MouseLock Overlay (Cursor-Free) for Roblox

A lightweight **LocalScript overlay** that adds mouse-lock style character facing  
**without overriding Roblox’s default movement system**.

✅ Improvements Over Roblox Default Shift Lock

### 1. Cursor-Free MouseLock
- Cursor is **not locked** to the center
- UI interaction remains possible while active

### 2. No Movement Override
This script does **NOT**:
- Change `Humanoid.WalkSpeed`
- Change `Humanoid.JumpPower` / `JumpHeight`
- Apply custom velocity or physics
- Replace Roblox movement logic

Your game controls:
- Walking speed
- Sprint behavior
- Jump height & gravity

### 3. Overlay-Based Design
- Only rotates character **yaw** to face camera direction
- Position, velocity, and physics are untouched

### 4. Compatible with Existing Systems
Safe to use alongside:
- Custom sprint scripts
- Custom jump logic
- Animation controllers
- Other movement-related systems

No property conflicts. No “script fighting”.

### 5. Minimal & Clean UI
- Only two buttons:
  - `SCRIPT: ON / OFF`
  - `DESTROY`
- Press **comma ( , )** to hide/show the entire UI instantly
- Clean gameplay view without destroying the script

### 6. Fully Responsive UI
Automatically adapts to:
- PC & Laptop
- Tablet
- Mobile

Uses anchors, scale-based positioning, and UIScale.

### 7. Lightweight & Performance Friendly
- Single `RenderStepped` connection
- No loops, raycasts, physics, or sound systems
- Negligible performance cost (safe for mobile)

---

## 🧩 Controls

| Action | Input |
|------|------|
| Toggle Script | UI Button |
| Hide / Show UI | `,` (Comma) |
| Destroy Script | UI Button |

> When `SCRIPT: ON`, mouse-lock facing is active automatically.

---

## ⚠️ Notes

- Cursor remains free by design
- Does not replicate movement changes to the server
- Meant as an overlay, not a full movement replacement
