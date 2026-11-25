#!/usr/bin/env bun
// Espelha os atalhos que o Steam (flatpak) cria dentro da sandbox para
// ~/.local/share, trocando `Exec=steam` por `flatpak run`. Remove os atalhos
// espelhados cujo original sumiu da sandbox.
import { copyFile, mkdir, readdir, rm, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

const FLATPAK_ID = "com.valvesoftware.Steam";
const PREFIX = "steam-flatpak-";
const MARKER = "X-Steam-Flatpak-Shortcut=true";

const home = homedir();
const src = join(home, ".var/app", FLATPAK_ID, ".local/share");
const dst = join(home, ".local/share");

const exists = (path: string) => stat(path).then(() => true, () => false);

async function iconSizes(root: string): Promise<string[]> {
  return (await exists(root)) ? readdir(root) : [];
}

let changed = false;

// appid -> conteúdo do .desktop reescrito
const shortcuts = new Map<string, string>();
for (const name of await readdir(join(src, "applications")).catch(() => [])) {
  if (!name.endsWith(".desktop")) continue;
  const text = await Bun.file(join(src, "applications", name)).text();
  const appId = text.match(/steam:\/\/rungameid\/(\d+)/)?.[1];
  if (!appId) continue;
  const rewritten = text
    .replace(/^Exec=steam /m, `Exec=flatpak run ${FLATPAK_ID} `)
    .trimEnd() + `\n${MARKER}\n`;
  shortcuts.set(appId, rewritten);
}

await mkdir(join(dst, "applications"), { recursive: true });
for (const [appId, content] of shortcuts) {
  const target = join(dst, "applications", `${PREFIX}${appId}.desktop`);
  const current = (await exists(target)) ? await Bun.file(target).text() : null;
  if (current !== content) {
    await Bun.write(target, content);
    changed = true;
  }

  const icon = `steam_icon_${appId}.png`;
  for (const size of await iconSizes(join(src, "icons/hicolor"))) {
    const from = join(src, "icons/hicolor", size, "apps", icon);
    if (!(await exists(from))) continue;
    const to = join(dst, "icons/hicolor", size, "apps", icon);
    const fromTime = (await stat(from)).mtimeMs;
    const toTime = (await exists(to)) ? (await stat(to)).mtimeMs : 0;
    if (fromTime <= toTime) continue;
    await mkdir(join(dst, "icons/hicolor", size, "apps"), { recursive: true });
    await copyFile(from, to);
    changed = true;
  }
}

// Remove espelhos órfãos (jogo desinstalado ou atalho apagado no Steam)
for (const name of await readdir(join(dst, "applications"))) {
  const appId = name.match(new RegExp(`^${PREFIX}(\\d+)\\.desktop$`))?.[1];
  if (!appId || shortcuts.has(appId)) continue;
  const path = join(dst, "applications", name);
  if (!(await Bun.file(path).text()).includes(MARKER)) continue;
  await rm(path);
  for (const size of await iconSizes(join(dst, "icons/hicolor"))) {
    await rm(join(dst, "icons/hicolor", size, "apps", `steam_icon_${appId}.png`), { force: true });
  }
  changed = true;
}

if (changed) {
  Bun.spawnSync(["update-desktop-database", join(dst, "applications")]);
  Bun.spawnSync(["gtk-update-icon-cache", "-f", "-t", join(dst, "icons/hicolor")]);
}
