import { component$ } from "@qwik.dev/core";
import { Link } from "@qwik.dev/router";

export default component$(() => (
  <main>
    <h1>About</h1>
    <Link href="/home/">Home</Link>
  </main>
));
