#!/usr/bin/env bun
// Destranca o login keyring de um gnome-keyring-daemon já em execução pelo
// socket de controle, como o pam_gnome_keyring faz (gkd_control_unlock).
// Lê a senha do stdin. Sai com 0 se o daemon respondeu OK.
import { connect } from "node:net";

const OP_UNLOCK = 1;
const RESULT_OK = 0;

const runtimeDir = process.env.XDG_RUNTIME_DIR ?? `/run/user/${process.getuid?.()}`;
const path = `${runtimeDir}/keyring/control`;

const password = Buffer.from(await Bun.stdin.text());

const packet = Buffer.alloc(12 + password.length);
packet.writeUInt32BE(packet.length, 0);
packet.writeUInt32BE(OP_UNLOCK, 4);
packet.writeUInt32BE(password.length, 8);
password.copy(packet, 12);

const result = await new Promise<number>((resolve, reject) => {
  let reply = Buffer.alloc(0);
  const sock = connect({ path }, () => {
    // Byte de credenciais: o daemon confere o UID via SO_PEERCRED
    sock.write(Buffer.from([0]));
    sock.write(packet);
  });
  sock.on("data", (chunk) => {
    reply = Buffer.concat([reply, chunk]);
    if (reply.length >= 4 && reply.length >= reply.readUInt32BE(0)) {
      sock.end();
      resolve(reply.readUInt32BE(4));
    }
  });
  sock.on("error", reject);
  sock.on("close", () => reject(new Error("socket fechado sem resposta")));
});

password.fill(0);
packet.fill(0);

if (result !== RESULT_OK) {
  console.error(`gnome-keyring respondeu ${result}`);
  process.exit(1);
}
