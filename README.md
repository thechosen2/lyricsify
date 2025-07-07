# Lyricsify (WIP Name)

Simple flutter app that overlays synced lyrics of any music you're playing, for people that don't want to pay a monthly subscription to yet another app. Made so that you can enjoy epic gaming experiences such as [this](https://youtu.be/OIiuG-nLTts), because listening to a song with lyrics on is like watching a movie with subs, even if you don't need it, sometimes you feel better because it's there.



## Features

- Transparent overlay that floats on top of all apps  
- Automatically picks up song info from media notifications  
- Works without Spotify or other service logins

## Getting Started

Clone the repo:

```bash
git clone https://github.com/thechosen2/lyricsify.git
cd lyricsify
```

Run the app:
```bash
flutter pub get
flutter run
```


You might need to grant "draw over other apps" permission manually if the app doesn't start the overlay the first time.

## Notes
- Currently only for Android.
- The app picks up metadata from media player notifications, so it works with most major music apps.
- Lyrics are fetched from [lrclib.net](lrclib.net)'s api using the artist and title parsed from the notification.

## Debug Tips
- If the overlay doesn't show, make sure the overlay permission is granted.
- If lyrics don't show up, it's likely a 400 error from the server (either bad parsing or missing lyrics).
- You can stop the overlay from inside the app using the "Stop" button.

## Todo
- Add font picker for overlay text
- Add persistent notification or quick tile to toggle overlay
- Support manual song entry as fallback

Made with Flutter and a bit of frustration
