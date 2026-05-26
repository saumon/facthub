// Fact Hub Landing Page — Progressive Enhancement
// Non-critical: page remains fully usable without this script.

(function () {
  "use strict";

  // Mobile navigation toggle
  const toggle = document.querySelector(".mobile-menu-toggle");
  const navLinks = document.querySelector(".nav-links");

  if (toggle && navLinks) {
    toggle.addEventListener("click", function () {
      const expanded = toggle.getAttribute("aria-expanded") === "true";
      toggle.setAttribute("aria-expanded", String(!expanded));
      navLinks.classList.toggle("active");
    });

    // Close menu when a nav link is clicked
    navLinks.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        navLinks.classList.remove("active");
        toggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // Scroll-reveal animation using IntersectionObserver
  var fadeElements = document.querySelectorAll(".fade-in");
  if (fadeElements.length > 0 && "IntersectionObserver" in window) {
    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1, rootMargin: "0px 0px -50px 0px" }
    );

    fadeElements.forEach(function (el) {
      observer.observe(el);
    });
  } else {
    // Fallback: show everything immediately
    fadeElements.forEach(function (el) {
      el.classList.add("visible");
    });
  }

  // Header background enhancement on scroll
  var header = document.getElementById("header");
  if (header) {
    var scrolled = false;
    window.addEventListener("scroll", function () {
      if (window.scrollY > 50 && !scrolled) {
        header.style.background = "rgba(15, 23, 42, 0.95)";
        header.style.borderBottomColor = "rgba(99, 102, 241, 0.15)";
        scrolled = true;
      } else if (window.scrollY <= 50 && scrolled) {
        header.style.background = "rgba(15, 23, 42, 0.85)";
        header.style.borderBottomColor = "rgba(99, 102, 241, 0.08)";
        scrolled = false;
      }
    });
  }
})();
