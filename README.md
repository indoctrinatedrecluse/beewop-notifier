# Beewop

Beewop receives GitHub webhooks and delivers actionable notifications to Discord.

## Project overview

Beewop is a small, self-hosted notification relay for GitHub activity. It accepts signed GitHub
webhook deliveries, filters them to the events that matter, records every notification locally,
and posts a concise alert to a Discord channel. Its dashboard provides a live view of recent
deliveries and whether Discord accepted them.

The initial release handles:

- Failed GitHub Actions workflow runs
- Newly created and published GitHub releases

## Stack

- **Elixir and OTP** — fault-tolerant runtime and asynchronous notification delivery
- **Phoenix 1.8** — HTTP endpoint, routing, and development server
- **Phoenix LiveView** — live, minimal dashboard without a separate frontend application
- **Ecto with SQLite** — persistent webhook delivery history for a simple single-user deployment
- **Req** — HTTP client used to post Discord incoming-webhook messages
- **Tailwind CSS** — responsive dashboard styling

## Build and run locally

### Prerequisites

- Erlang/OTP and Elixir (the project requires Elixir 1.15 or newer)
- GitHub repository admin access to configure a webhook
- A Discord channel webhook URL

If Elixir was installed with the Windows installer used for this project, add its binaries to
the current PowerShell session before running Mix:

```powershell
$env:PATH = "$env:USERPROFILE\.elixir-install\installs\otp\28.1\erts-16.1\bin;$env:PATH"
$env:PATH = "$env:USERPROFILE\.elixir-install\installs\elixir\1.19.0-otp-28\bin;$env:PATH"
```

### Configure secrets

Set these values in the shell that will run Beewop. Do not commit them to the repository.

```powershell
$env:GITHUB_WEBHOOK_SECRET = "your-github-webhook-secret"
$env:DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/..."
```

### Install, migrate, and start

```powershell
mix setup
mix phx.server
```

`mix setup` installs dependencies, creates the local SQLite database, runs migrations, and
builds assets. Open <http://localhost:4000> once the server is running.

### Configure GitHub

Expose the local server through a public HTTPS tunnel during development, then create a GitHub
repository webhook with:

- **Payload URL:** `https://your-public-host/webhooks/github`
- **Content type:** `application/json`
- **Secret:** the value of `GITHUB_WEBHOOK_SECRET`
- **Events:** **Workflow runs** and **Releases**

Beewop alerts on completed failed workflow runs, and releases that are created or published.

### Verify changes

Run the project checks before committing:

```powershell
mix precommit
```
