import { component$ } from "@qwik.dev/core";
import { routeLoader$ } from "@qwik.dev/router";

// The page at "/" sends visitors on to /home/. The redirect is thrown from a routeLoader$.
// It has nothing to do with the root layout's loader (src/routes/layout.tsx).
export const useLanding = routeLoader$(
  ({ redirect }) => {
    console.log("[repro] useLanding ran");
    throw redirect(302, "/home/");
  },
  { id: "landing" },
);

export default component$(() => <p>landing (always redirects)</p>);
