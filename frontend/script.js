async function fetchData() {
  const name = document.getElementById("nameInput").value;
  if (!name) return;

  const res = await fetch(`/api/nameinfo?name=${name}`);
  const data = await res.json();

  let html = `<p><strong>Name:</strong> ${data.name}</p>`;
  html += `<p><strong>Gender:</strong> ${data.gender} (${data.probability})</p>`;
  html += `<strong>Country:</strong><ul>`;

  data.country.forEach((c, i) => {
    const flagUrl = data.flags[i] || "";
    html += `
      <li>
        <img src="${flagUrl}" alt="${c.country_id}" width="32" height="20">
        ${c.country_id} (${c.probability.toFixed(2)})
      </li>
    `;
  });

  html += `</ul>`;
  document.getElementById("result").innerHTML = html;
}
