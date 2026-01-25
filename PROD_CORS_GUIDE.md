# Production CORS Hardening

CORS is controlled via the `CORS_ORIGINS` environment variable.

## Recommended Settings

- Set `CORS_ORIGINS` to your **actual frontend origin(s)** only.
- Comma-separated list, no spaces.

Example:
```
CORS_ORIGINS=https://main.d123abc.amplifyapp.com,https://www.yourdomain.com
```

## Where to Set

- GitHub Actions → Secrets → `CORS_ORIGINS`
- EC2 deployment workflow uses this secret to set the container env.

## Validate

Test from your browser frontend only.
Requests from other origins should be blocked by the browser.

## Notes

- Avoid using `*` in production.
- If you use both Amplify and a custom domain, include both.
