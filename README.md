# AI Pod

AI Pod takes large hundred+ page reports published by the government and turns them into AI generated podcasts. We digest complex policy documents and turn them into engaging, accessible audio content.

## Technology Stack

- **Hugo** - Static site generator
- **Castanet Theme** - Podcast theme with RSS feed generation
- **Cloudflare R2** - Audio file storage (100MB+ files)
- **Cloudflare Pages** - Static site deployment

## Local Development

Install Hugo (recommended version 0.156.0 or later):

```bash
# macOS
brew install hugo

# Start dev server
hugo server -D
```

Visit http://localhost:1313 to view the site.

## Cloudflare Pages Deployment

### 1. Build Settings

In Cloudflare Pages → Create application → Connect to Git:

| Setting | Value |
|---------|-------|
| Production branch | `main` |
| Build command | `./build.sh` |
| Build output directory | `public` |

### 2. Environment Variables

Add to **Settings → Environment Variables** (both Production and Preview):

| Variable | Value |
|----------|-------|
| `HUGO_VERSION` | `0.156.0` |

### 3. Build Script

The `build.sh` script handles base URL configuration:

```bash
if [ "$CF_PAGES_BRANCH" = "main" ]; then
  hugo --minify
else
  hugo -b "$CF_PAGES_URL" --minify
fi
```

- Production builds use the real domain (`aipod.nz`)
- Preview builds use `$CF_PAGES_URL` for testing

## Cloudflare R2 Setup

### 1. Create R2 Bucket

In Cloudflare Dashboard → R2 → Create bucket:

- Bucket name: `aipod-audio` (or similar)
- Enable public access (or use custom domain)

### 2. Add Custom Domain

In bucket settings → Custom Domains → Add domain:

- Domain: `cdn.aipod.nz` (or your preferred subdomain)
- This enables caching and CDN distribution

### 3. Upload Audio Files

Audio files should be uploaded to R2 under the `audio/` prefix:

```
audio/
  001-intro.mp3
  002-something.mp3
  ...
```

### 4. Configure Headers

Set appropriate headers for audio files:

- `Content-Type: audio/mpeg`
- `Accept-Ranges: bytes` (for seeking in podcast players)

## Adding Episodes

1. Create new episode content:

```bash
hugo new episode/002-title.md
```

2. Edit episode frontmatter:

```toml
+++
Date = "2026-02-25T08:00:00+13:00"
podcast_file = "002-title.mp3"
podcast_duration = "X:XX"
episode = "2"
title = "Episode Title"
explicit = "no"

categories = ["Government"]
tags = ["tag1", "tag2"]
+++

Episode content here...
```

3. Upload audio file to R2: `audio/002-title.mp3`
4. Build and commit changes

## RSS Feed

The podcast RSS feed is automatically generated at:

- `/episode/index.xml` - Main podcast feed (Apple Podcasts, Spotify, etc.)
- `/index.xml` - General site RSS

The feed is configured in `hugo.toml` under `[params.feed]`.

## Asset Requirements

### Podcast Art

- Minimum: 1400×1400px
- Maximum: 3000×3000px
- Format: JPG or PNG
- Location: R2 at `https://cdn.aipod.nz/img/podcast-art.jpg`

### Episode Images

- Recommended: 1400×1400px
- Format: JPG or PNG
- Location: `content/episode/` or R2

## Feed Validation

Before submitting to Apple/Spotify:

1. Validate with [Feed Validator](https://validator.w3.org/feed/)
2. Test sample audio download from enclosures
3. Verify all metadata fields

## Important Notes

- Never hand-edit the RSS XML - it's generated from Hugo content
- Keep `media_prefix` stable - podcast clients cache aggressively
- Test feed changes in preview deployments before merging to main
- Pin HUGO_VERSION in Pages settings for consistent builds