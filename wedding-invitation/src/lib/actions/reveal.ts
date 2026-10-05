// Gentle scroll-reveal. Does nothing for reduced-motion users (CSS keeps content visible).
export function reveal(node: HTMLElement, delay = 0) {
  if (typeof IntersectionObserver === "undefined") return;

  node.classList.add("reveal");
  node.style.setProperty("--reveal-delay", `${delay}s`);

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          node.classList.add("is-visible");
          observer.disconnect();
        }
      }
    },
    { threshold: 0.12 },
  );
  observer.observe(node);

  return { destroy: () => observer.disconnect() };
}