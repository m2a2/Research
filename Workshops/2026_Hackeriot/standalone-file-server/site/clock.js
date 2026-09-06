// Also just a file. The server hands it over verbatim, exactly like the CSS,
// and has no idea it is code. Everything below runs in the browser, not here.
const today = document.getElementById("today");

document.getElementById("refresh").addEventListener("click", () => {
  const now = new Date();
  today.dateTime = now.toISOString().slice(0, 16);
  today.textContent = now.toLocaleDateString(undefined, {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
});
