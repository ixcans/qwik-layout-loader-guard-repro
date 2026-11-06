import { component$, Slot } from "@qwik.dev/core";
import { routeLoader$ } from "@qwik.dev/router";

// A loader of the root layout. Any layout loader will do; the explicit id only makes the
// loader's URL predictable for check.sh.
export const useLayoutData = routeLoader$(() => ({ ok: true }), { id: "layout-data" });

export default component$(() => {
  const data = useLayoutData();
  return (
    <div data-layout-ok={String(data.value.ok)}>
      <Slot />
    </div>
  );
});
