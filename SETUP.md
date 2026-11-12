# Farukh's Prompter: put it on your iPhone

You do this once. After that, each new version takes about 5 minutes.

## What you need (all free)

- A **GitHub** account: https://github.com/signup
- Your **Apple ID** (the one on your iPhone)
- **Sideloadly** on your Windows PC: https://sideloadly.io
- **iTunes** for Windows from apple.com (Sideloadly needs it to talk to the iPhone)
- A USB cable

## Part 1: Let GitHub build the app (a free online Mac)

1. Sign in to GitHub and create a **new repository**. Call it `farukhs-prompter`. Keep it **Private**.
2. Upload everything in this folder (`D:\Ihone Teleprompter`) to that repository.
   Easiest way: open the new repository page, click **"uploading an existing file"**, then drag all the files and folders in, including the hidden `.github` folder.
3. Click the **Actions** tab. The build starts by itself. It takes about 5 minutes.
4. When it shows a green tick, open the run and download **FarukhsPrompter-ipa** from the Artifacts section at the bottom. Unzip it to get `FarukhsPrompter.ipa`.

If the build shows a red cross, open it, copy the error text and send it to me. I'll fix the code.

## Part 2: Install on your iPhone

1. Plug in the iPhone and tap **Trust** on the phone.
2. Open Sideloadly, drag `FarukhsPrompter.ipa` into it, and enter your Apple ID.
3. Press **Start** and enter your Apple ID password when asked.
4. On the iPhone open **Settings > General > VPN & Device Management**, tap your Apple ID, then **Trust**.
5. If iOS asks for it, turn on **Settings > Privacy & Security > Developer Mode** and restart the phone.
6. Open **Farukh's Prompter** on the home screen.

## Every 7 days

Apps installed with a free Apple ID stop opening after 7 days. Plug in the phone and press Start in Sideloadly again. Your scripts stay saved.

## Part 3: The Windows version (web app)

It lives in the `docs` folder, so it uploads with everything else.

**Try it right now, no setup:** double-click `docs\index.html`. It opens in your browser and works.

**To get a proper installed app:**
1. In your GitHub repository open **Settings > Pages**.
2. Under **Branch**, choose `main` and the folder `/docs`, then press **Save**.
3. After a minute GitHub shows your address, like `https://yourname.github.io/farukhs-prompter/`. The repository is private, so the page may need a paid GitHub plan. If Pages is greyed out, make the repository **Public**. It holds only code, never your scripts.
4. Open that address in **Edge or Chrome** and click the **Install** icon in the address bar. It gets a desktop icon and works offline.
5. On the iPhone, open the same address in **Safari**, tap **Share**, then **Add to Home Screen**. This version never expires.

**Keyboard shortcuts in the prompter:** Space play/pause, Up/Down speed, + and - size, M mirror, R restart, Esc close.

**Moving scripts between devices:** Settings > Export saves a file, and Settings > Import loads it on the other device.
