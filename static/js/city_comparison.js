let lastCityResult = null;

async function runCityComparison() {
  const btn = document.getElementById("cityCompBtn");
  const cityA = document.getElementById("city_a").value;
  const cityB = document.getElementById("city_b").value;
  const salaryA = parseFloat(document.getElementById("salary_a").value) || 0;
  const salaryB = parseFloat(document.getElementById("salary_b").value) || 0;

  if (salaryA <= 0 || salaryB <= 0) { alert("Please enter salaries for both cities."); return; }
  if (cityA === cityB) { alert("Please select two different cities."); return; }

  btn.querySelector("span").textContent = "Comparing...";
  btn.disabled = true;

  try {
    const res = await fetch("/calculate-city-comparison", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ city_a: cityA, city_b: cityB, salary_a: salaryA, salary_b: salaryB })
    });
    const r = await res.json();
    lastCityResult = r;
    renderCityResults(r);
    document.getElementById("cityResults").classList.remove("hidden");
    document.getElementById("cityResults").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch(err) { alert("Something went wrong. Please try again."); }
  finally { btn.querySelector("span").textContent = "Compare Cities"; btn.disabled = false; }
}

function renderCityResults(r) {
  const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
  const winnerIsA = r.better_city === document.getElementById("city_a").value;
  const winnerName = winnerIsA ? r.city_a.name : r.city_b.name;
  const loserName = winnerIsA ? r.city_b.name : r.city_a.name;

  document.getElementById("city_winner_name").textContent = winnerName;
  document.getElementById("city_winner_name").style.color = winnerIsA ? "var(--accent)" : "var(--white)";

  document.getElementById("city_headline").innerHTML =
    `gives you <strong>${fmt(r.disposable_diff)}/month more</strong> in disposable income`;

  document.getElementById("city_salary_needed_city").textContent = r.salary_needed_city;
  document.getElementById("city_salary_needed").textContent = fmt(r.salary_needed);

  // City A
  document.getElementById("city_label_a").textContent = r.city_a.name.toUpperCase();
  document.getElementById("city_a_disposable").textContent = fmt(r.city_a.disposable);
  document.getElementById("city_a_disposable").style.color = winnerIsA ? "var(--accent)" : "var(--white)";
  document.getElementById("city_a_takehome").textContent = fmt(r.city_a.take_home_monthly);
  document.getElementById("city_a_rent").textContent = fmt(r.city_a.rent);
  document.getElementById("city_a_transport").textContent = fmt(r.city_a.transport);
  document.getElementById("city_a_groceries").textContent = fmt(r.city_a.groceries);
  document.getElementById("city_a_utilities").textContent = fmt(r.city_a.utilities);
  document.getElementById("city_a_costs").textContent = fmt(r.city_a.monthly_costs);
  document.getElementById("city_col_a").style.borderColor = winnerIsA ? "var(--accent)" : "var(--border)";

  // City B
  document.getElementById("city_label_b").textContent = r.city_b.name.toUpperCase();
  document.getElementById("city_b_disposable").textContent = fmt(r.city_b.disposable);
  document.getElementById("city_b_disposable").style.color = winnerIsA ? "var(--white)" : "var(--accent)";
  document.getElementById("city_b_takehome").textContent = fmt(r.city_b.take_home_monthly);
  document.getElementById("city_b_rent").textContent = fmt(r.city_b.rent);
  document.getElementById("city_b_transport").textContent = fmt(r.city_b.transport);
  document.getElementById("city_b_groceries").textContent = fmt(r.city_b.groceries);
  document.getElementById("city_b_utilities").textContent = fmt(r.city_b.utilities);
  document.getElementById("city_b_costs").textContent = fmt(r.city_b.monthly_costs);
  document.getElementById("city_col_b").style.borderColor = winnerIsA ? "var(--border)" : "var(--accent)";
}

function shareCityComparison(platform) {
  if (!lastCityResult) return;
  const r = lastCityResult;
  const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
  const winnerIsA = r.better_city === document.getElementById("city_a").value;
  const winner = winnerIsA ? r.city_a.name : r.city_b.name;
  const loser = winnerIsA ? r.city_b.name : r.city_a.name;
  const text = `I compared ${r.city_a.name} and ${r.city_b.name} salaries. ${winner} gives me ${fmt(r.disposable_diff)}/month more in disposable income. To match my ${winner} lifestyle in ${r.salary_needed_city} I would need to earn ${fmt(r.salary_needed)}. traveltax.co.uk/city-comparison`;
  if (platform === "twitter") window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(text), "_blank");
  else if (platform === "whatsapp") window.open("https://wa.me/?text=" + encodeURIComponent(text), "_blank");
  else if (platform === "linkedin") window.open("https://www.linkedin.com/sharing/share-offsite/?url=" + encodeURIComponent("https://traveltax.co.uk/city-comparison"), "_blank");
  else if (platform === "copy") navigator.clipboard.writeText(text).then(() => alert("Copied!"));
}
