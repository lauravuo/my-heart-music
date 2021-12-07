# my-❤️-music

This project is a PoC for utilizing GitHub Action workflows for static website generation.

The idea is to create static websites with low or zero coding:

* Fetch data from an API (in the PoC case, [Spotify top tracks](https://developer.spotify.com/console/get-current-user-top-artists-and-tracks/)) and export the data to markdown
* Append the generated  markdown to a [Hugo](https://gohugo.io/) static website project
* Build the Hugo site and deploy it to GitHub pages.

[The result site](https://lauravuo.github.io/my-heart-music/) displays my top tracks from Spotify with [Hugo Terminal theme](https://github.com/panr/hugo-theme-terminal). The page is updated with a scheduled GitHub action, once per week.

A similar model could be easily used to generate different kind of sites, by variating the data sources and Hugo themes.

## Action for Fetching Data

The inspiration to use the Spotify API for this project came to me when browsing Spotify related actions in GitHub Actions Marketplace. [Spotify Box](https://github.com/marketplace/actions/spotify-box) is an action that fetches the user's top tracks and updates those to a Gist. I took spotify-box as the basis and modified [my fork](https://github.com/lauravuo/spotify-box) according to my needs:
* Instead of exporting the result to a Gist, I export the API result to json (`tracks.json`) and markdown (`tracks.md`).
* I removed unneeded dependencies and added `node_modules` to version control, so that also external projects (other than the action repository) can easily take the action in use.

The use of the action is easy, the trickiest part is to acquire the needed Spotify keys and tokens. Luckily, spotify-box authors have described this process [very detailed](https://github.com/marketplace/actions/spotify-box#1-create-new-spotify-application). The keys and tokens need to be added as secrets to the repository using the action, so that they are not exposed accidentally when the action is run.

After the API action is run, the result data files are saved and pushed to this repository. Markdown file is copied to target path `hugo-site/content/index.md`. It will be the source markdown for the site's landing page.

```yml
  updateTopTracks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: lauravuo/spotify-box@main
        env:
          SPOTIFY_CLIENT_ID: ${{ secrets.SPOTIFY_CLIENT_ID }}
          SPOTIFY_CLIENT_SECRET: ${{ secrets.SPOTIFY_CLIENT_SECRET }}
          SPOTIFY_REFRESH_TOKEN: ${{ secrets.SPOTIFY_REFRESH_TOKEN }}
      - run: |
          git config --global user.email "spotify-bot"
          git config --global user.name "spotify-bot"
          cp tracks.md hugo-site/content/index.md
          git add tracks.*
          git commit -a -m "Add latest tracks."
          git push
```

## Deploying the Hugo Site

If the data fetch from previous step succeeds, the workflow continues by building the static website with Hugo. Hugo is setup using action [peaceiris/actions-hugo](https://github.com/marketplace/actions/hugo-setup). When the files are ready, the result is published to GitHub pages, using another GitHub action, [peaceiris/actions-gh-pages](https://github.com/marketplace/actions/github-pages-action).

```yml
 deploy:
    needs: updateTopTracks
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: recursive
          fetch-depth: 1

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
          extended: true

      - name: Build
        run: cd hugo-site && hugo --minify

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./hugo-site/public
 ```
