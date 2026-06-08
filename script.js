const navToggle = document.querySelector(".nav-toggle");
const navLinks = document.querySelector(".nav-links");
const searchInput = document.querySelector("#post-search");
const categoryFilter = document.querySelector("#category-filter");
const postCards = Array.from(document.querySelectorAll(".post-card"));
const emptyState = document.querySelector("#empty-state");
const topicLinks = document.querySelectorAll("[data-topic-link]");
const newsletterForm = document.querySelector(".newsletter-form");
const formNote = document.querySelector(".form-note");

navToggle?.addEventListener("click", () => {
  const isOpen = navLinks.classList.toggle("is-open");
  navToggle.setAttribute("aria-expanded", String(isOpen));
});

navLinks?.addEventListener("click", (event) => {
  if (event.target instanceof HTMLAnchorElement) {
    navLinks.classList.remove("is-open");
    navToggle?.setAttribute("aria-expanded", "false");
  }
});

function filterPosts() {
  const query = searchInput.value.trim().toLowerCase();
  const category = categoryFilter.value;
  let visibleCount = 0;

  postCards.forEach((card) => {
    const title = card.dataset.title.toLowerCase();
    const cardCategory = card.dataset.category;
    const matchesQuery = !query || title.includes(query) || card.textContent.toLowerCase().includes(query);
    const matchesCategory = category === "all" || cardCategory === category;
    const isVisible = matchesQuery && matchesCategory;

    card.hidden = !isVisible;
    if (isVisible) {
      visibleCount += 1;
    }
  });

  emptyState.hidden = visibleCount > 0;
}

searchInput?.addEventListener("input", filterPosts);
categoryFilter?.addEventListener("change", filterPosts);

topicLinks.forEach((link) => {
  link.addEventListener("click", () => {
    categoryFilter.value = link.dataset.topicLink;
    filterPosts();
  });
});

newsletterForm?.addEventListener("submit", (event) => {
  event.preventDefault();
  const emailInput = newsletterForm.querySelector("input[type='email']");

  formNote.textContent = `Thanks, ${emailInput.value}! You are on the list.`;
  newsletterForm.reset();
});
