# Spark Racquetball — Setup Guide

Estimated time: **20–30 minutes**, one-time only.
After this, your group just uses a URL. No more setup ever.

---

## What you'll end up with

- A URL like `https://spark-racquetball.web.app` (or a custom name you choose)
- All session data stored in Google's Firebase cloud — shared across all players in real time
- Works on any phone browser, and can be "installed" to the home screen like an app

---

## Step 1 — Create a Google / Firebase account

1. Go to **https://firebase.google.com**
2. Click **Get started** and sign in with your Google account (or create one)

---

## Step 2 — Create a Firebase project

1. In the Firebase console, click **Add project**
2. Name it something like `spark-racquetball`
3. **Disable Google Analytics** (not needed) → click **Create project**
4. Wait ~30 seconds for it to provision, then click **Continue**

---

## Step 3 — Set up the Realtime Database

1. In the left sidebar, click **Build → Realtime Database**
2. Click **Create database**
3. Choose your region: **United States (us-central1)** is fine
4. When asked about security rules, choose **Start in test mode** → click **Enable**
   > Test mode allows all reads and writes for 30 days. You'll lock it down in Step 7.
5. You'll see a URL like `https://spark-racquetball-default-rtdb.firebaseio.com`
   **Copy this URL — you'll need it in Step 5.**

---

## Step 4 — Register your web app & get your config

1. In the Firebase console, click the **gear icon ⚙️** next to "Project Overview" → **Project settings**
2. Scroll down to **Your apps** → click the **</>** (Web) icon
3. Give it a nickname: `spark-web` → click **Register app**
4. You'll see a block of code that looks like this:

```js
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "spark-racquetball.firebaseapp.com",
  databaseURL: "https://spark-racquetball-default-rtdb.firebaseio.com",
  projectId: "spark-racquetball",
  storageBucket: "spark-racquetball.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

**Copy the entire block** — you need all 7 values.

5. Click **Continue to console**

---

## Step 5 — Paste your config into index.html

1. Open **index.html** in any text editor (Notepad, TextEdit, VS Code, etc.)
2. Find this section near the bottom (search for `PASTE_YOUR_API_KEY_HERE`):

```js
const firebaseConfig = {
  apiKey:            "PASTE_YOUR_API_KEY_HERE",
  authDomain:        "PASTE_YOUR_PROJECT_ID.firebaseapp.com",
  databaseURL:       "PASTE_YOUR_DATABASE_URL_HERE",
  ...
};
```

3. Replace every placeholder value with the values from Step 4
4. **Save the file**

---

## Step 6 — Deploy to Firebase Hosting

You'll do this from your computer's terminal (Mac: Terminal app, Windows: Command Prompt or PowerShell).

### Install Node.js (if you don't have it)
- Download from **https://nodejs.org** → choose the "LTS" version → install

### Install Firebase CLI
Open Terminal and run:
```bash
npm install -g firebase-tools
```

### Log in
```bash
firebase login
```
A browser window will open — sign in with your Google account.

### Deploy
Navigate to the folder containing your app files, then run:
```bash
cd /path/to/spark-racquetball    # adjust to wherever you saved the files
firebase use --add               # select your project from the list
firebase deploy
```

Firebase will upload your files and give you a **Hosting URL**, like:
```
✔  Hosting URL: https://spark-racquetball.web.app
```

**That's your app URL. Share it with your group!**

---

## Step 7 — Lock down the database (important, do this after testing)

The default "test mode" database rules expire after 30 days. To make them permanent and secure:

1. Go to Firebase console → **Realtime Database → Rules**
2. Replace the rules with this:

```json
{
  "rules": {
    "sessions": {
      ".read": true,
      ".write": true
    }
  }
}
```

3. Click **Publish**

> **Why no login?** For a private group of 5 friends, open read/write keeps things simple —
> no passwords, no accounts. The database URL isn't public unless you share it.
> If you ever want proper user authentication added, just ask Claude to add it.

---

## Step 8 — Add to home screen (share with your group)

**iPhone (Safari):**
1. Open the app URL in Safari
2. Tap the **Share** button (box with arrow)
3. Tap **Add to Home Screen** → **Add**

**Android (Chrome):**
1. Open the app URL in Chrome
2. Tap the **⋮ menu** → **Add to Home screen** → **Add**

The app will appear on the home screen with its own icon, opening full-screen with no browser chrome — just like a native app.

---

## Redeploying after changes

Any time you edit `index.html`, just run `firebase deploy` again from the project folder. Takes about 10 seconds.

---

## Troubleshooting

**"Permission denied" error in the app**
→ Check your database rules in the Firebase console (Step 7)

**App shows loading spinner but never loads data**
→ Your `databaseURL` in `index.html` is probably wrong. Double-check Step 5.

**"firebase: command not found"**
→ Node.js may not have installed correctly. Try closing and reopening Terminal, then `npm install -g firebase-tools` again.

**I want a custom domain (e.g. sparkracquetball.com)**
→ Firebase Hosting supports custom domains for free. In the console go to Hosting → Add custom domain.

---

## File reference

| File | Purpose |
|------|---------|
| `index.html` | The entire app (edit this to make changes) |
| `manifest.json` | Makes the app installable on home screens |
| `firebase.json` | Firebase hosting configuration |
| `database.rules.json` | Firebase database security rules |
| `SETUP-GUIDE.md` | This file |
