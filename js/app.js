document.addEventListener("DOMContentLoaded", () => {
  const grid = document.getElementById("posts-grid");
  if (!grid) return;

  posts.forEach(post => {
    const card = document.createElement("a");
    card.href = `post.html?id=${post.id}`;
    card.className = "post-card";
    card.innerHTML = `
      <span class="tag">${post.tag}</span>
      <h3>${post.title}</h3>
      <p class="excerpt">${post.excerpt}</p>
      <span class="meta">${post.date} &middot; ${post.author}</span>
    `;
    grid.appendChild(card);
  });
});
