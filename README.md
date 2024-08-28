## My Gists

GitHub doesn't allow one to export all gists in one shot (at least I've not found it yet!). Thought of adding my gists one at a time here and then maintaining it here instead. This repo is more like a backup.

Quick way to clone all gists repos is by installing github cli (gh) and then:

```
gh gist list -L 20|awk '{print $1;}' |xargs -I % sh -c 'gh gist clone %'
```

This will create one repo folder per gist.
