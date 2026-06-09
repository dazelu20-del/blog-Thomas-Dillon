# Vibe Blog

A simple, beautiful blog website built with plain HTML, CSS, and JavaScript. No frameworks, no build step.

## Features

- Clean, responsive design
- Blog post listing on the homepage
- Individual post pages
- Sample posts included

## Getting Started

Open `index.html` in your browser, or run a local server:

```bash
# Python
python -m http.server 8000

# Node.js (if npx is available)
npx serve .
```

Then visit [http://localhost:8000](http://localhost:8000).

## Adding Posts

Edit `js/posts.js` and add a new object to the `posts` array:

```js
{
  id: "my-new-post",        // URL slug (post.html?id=my-new-post)
  title: "My New Post",
  excerpt: "A short summary...",
  tag: "Category",
  date: "June 8, 2026",
  author: "Your Name",
  content: `<p>Your HTML content here.</p>`
}
```

## Project Structure

```
├── index.html      # Homepage with post listing
├── post.html       # Single post view
├── css/
│   └── style.css   # All styles
├── js/
│   ├── posts.js    # Post data
│   ├── app.js      # Homepage logic
│   └── post.js     # Post page logic
└── README.md
```
