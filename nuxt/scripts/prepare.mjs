// Runs after `pnpm install`: `nuxt prepare` writes the typed .nuxt folder.
import { spawnSync } from "node:child_process";

const result = spawnSync("nuxt", ["prepare"], { stdio: "inherit", shell: true });
process.exit(result.status ?? 1);
