# A layout's loader request runs the page at that path as a guard

Minimal reproduction for a Qwik Router report. `@qwik.dev/router` and `@qwik.dev/core` `2.0.0-rc.4`, Vite 8.2.4.

| file | what it is |
| --- | --- |
| [`src/routes/layout.tsx`](src/routes/layout.tsx) | root layout with a `routeLoader$` (`useLayoutData`, id `layout-data`) |
| [`src/routes/index.tsx`](src/routes/index.tsx) | the page at `/`; its `routeLoader$` (`useLanding`) redirects to `/home/` |
| [`src/routes/home/index.tsx`](src/routes/home/index.tsx) | page with a `<Link>` to `/about/` |
| [`src/routes/about/index.tsx`](src/routes/about/index.tsx) | page |

## Run

```sh
npm install
npm run build
npm run preview        # http://localhost:4173/
```

Open `/home/` directly and click **About**.

- Expected: the page ends on `/about/`.
- Actual (production build, default options): the page ends on `/home/`. The router navigates on the client; the page is not reloaded.

`npm run check` (`check.sh`) shows the request behind it without a browser.

## Why

After a navigation the client asks for the root layout's loader at the path the loader is recorded at, `/` (`/q-loader-layout-data.<hash>.json`). A production build with the default `strictLoaders` sends no page-path header, so the server matches `/` itself, and `runRouteGuards` (`loader-handler.ts`) runs every other blocking loader of that route before the requested one. That includes `useLanding`, the loader of the page at `/`, and its redirect becomes the answer to the layout loader's request. The same loader requested at `/home/` is answered with its own data.

## What I ran

Click **About** on `/home/`, headless Chromium:

| build | page ends on | `useLanding` runs |
| --- | --- | --- |
| `2.0.0-rc.4`, production | `/home/` | 2 |
| `main` at `bbcccb5` (preview build), production | `/home/` | 2 |
| `2.0.0-rc.4`, production, `qwikRouter({ strictLoaders: false })` | `/about/` | 0 |
| `2.0.0-rc.4`, `vite --mode ssr` | `/about/` | 0 |
| `2.0.0-rc.0`, production | `/about/` | 0 |

Two variations on `2.0.0-rc.4`, production:

- The same redirect in an `onGet` handler instead of a loader: the page ends on `/about/`, and the handler does not run for the layout loader's request.
- `useLanding` without the redirect (it only logs): the page ends on `/about/`, and `useLanding` still runs once per navigation. On `2.0.0-rc.0` it does not run.
