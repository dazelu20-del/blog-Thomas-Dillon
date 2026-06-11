---
name: wrangler
description: Cloudflare Workers CLI for deploying, developing, and managing Workers, KV, R2, D1, Vectorize, Hyperdrive, Workers AI, Containers, Queues, Workflows, Pipelines, and Secrets Store. Load before running wrangler commands to ensure correct syntax and best practices. Biases towards retrieval from Cloudflare docs over pre-trained knowledge.
---

# Wrangler CLI

Your knowledge of Wrangler CLI flags, config fields, and subcommands may be outdated. **Prefer retrieval over pre-training** for any Wrangler task.

## FIRST: Check if Wrangler is installed, and if not, install it

```bash
npx wrangler --version
npm install -D wrangler@latest
```

## Static site (this project)

Vibe Blog is plain HTML/CSS/JS with no build step. Deploy with Cloudflare Pages:

```bash
npx wrangler pages project create vibe-blog --production-branch main
npx wrangler pages deploy . --project-name=vibe-blog --branch main
```

Or deploy as a Worker with static assets via `wrangler.jsonc`:

```bash
npx wrangler deploy
```

## Auth

```bash
npx wrangler login
npx wrangler whoami
```

Set `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` for non-interactive deploys.

## Pages (Frontend Deployment)

```bash
wrangler pages project create my-site
wrangler pages deploy ./dist
wrangler pages deploy ./dist --branch main
wrangler pages deployment list --project-name my-site
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `command not found: wrangler` | `npm install -D wrangler` |
| Auth errors | Run `wrangler login` |
| Node not in PATH | Use full path to node.exe or add Node to PATH |
