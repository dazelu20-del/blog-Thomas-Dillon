document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("post-content");
  if (!container) return;

  const params = new URLSearchParams(window.location.search);
  const id = params.get("id");
  const post = getPostById(id);

  if (!post) {
    document.title = "Post Not Found — Vibe Blog";
    container.innerHTML = `
      <div class="post-not-found">
        <h1>Post not found</h1>
        <p>The post you're looking for doesn't exist or may have been removed.</p>
      </div>
    `;
    return;
  }

  document.title = `${post.title} — Vibe Blog`;
  container.innerHTML = `
    <header class="post-header">
      <span class="tag">${post.tag}</span>
      <h1>${post.title}</h1>
      <p class="meta">${post.date} &middot; ${post.author}</p>
    </header>
    <div class="post-body">${post.content}</div>
  `;
});
