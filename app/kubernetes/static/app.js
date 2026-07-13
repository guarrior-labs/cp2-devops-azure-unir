const correctOrder = [
    "Build Image",
    "Push Image",
    "Run Container",
    "Deploy to AKS"
];

const resultDiv = document.getElementById("result");

const hallOfFameDiv = document.getElementById("hallOfFame");

let shuffledSteps = [];
let selectedOrder = [];

const usernameInput = document.getElementById("username");
const startBtn = document.getElementById("startBtn");
const deployBtn = document.getElementById("deployBtn");
const stepsContainer = document.getElementById("stepsContainer");
const selectedContainer = document.getElementById("selectedOrder");

startBtn.addEventListener("click", startChallenge);

deployBtn.addEventListener("click", executeDeploy);

loadHallOfFame();

function shuffle(array) {

    return [...array].sort(() => Math.random() - 0.5);

}

async function startChallenge() {

const username = usernameInput.value.trim();

if (username === "") {

    alert("Debe ingresar un nombre.");

    return;

}

const response = await fetch("/api/player", {

    method: "POST",

    headers: {

        "Content-Type": "application/json"

    },

    body: JSON.stringify({

        user: username

    })

});

const result = await response.json();

if (!result.success) {

    alert(result.message);

    return;

}

if (result.existing) {

    alert("Bienvenido nuevamente " + username);

}
else {

    alert("Nuevo participante registrado.");

}

await loadHallOfFame();

shuffledSteps = shuffle(correctOrder);

selectedOrder = [];

resultDiv.className = "";

resultDiv.innerHTML = "Esperando...";  

deployBtn.disabled = true;

renderSteps();

renderSelection();

}

function renderSteps() {

    stepsContainer.innerHTML = "";

    shuffledSteps.forEach(step => {

        const card = document.createElement("div");

        card.className = "step-card";

        card.textContent = step;

        card.addEventListener("click", () => {

            if (card.classList.contains("locked")) {

                return;

            }

            selectStep(step, card);

        });

        stepsContainer.appendChild(card);

    });

}

function selectStep(step, card) {

    if (selectedOrder.includes(step)) {

        return;

    }

    selectedOrder.push(step);

    card.classList.add("selected");

    card.innerHTML =
        "<strong>(" +
        selectedOrder.length +
        ")</strong> " +
        step;

    if (selectedOrder.length === 4) {

        deployBtn.disabled = false;

        document
            .querySelectorAll(".step-card")
            .forEach(card => {

                card.classList.add("locked");

            });

    }

}

function renderSelection() {

    if (selectedOrder.length === 0) {

        selectedContainer.innerHTML =
            "Ningún paso seleccionado.";

        return;

    }

    selectedContainer.innerHTML = "";

    selectedOrder.forEach((step, index) => {

        selectedContainer.innerHTML +=
            "<p>" +
            (index + 1) +
            ". " +
            step +
            "</p>";

    });

}

async function executeDeploy() {

    let success = true;

    for (let i = 0; i < correctOrder.length; i++) {

        if (selectedOrder[i] !== correctOrder[i]) {

            success = false;
            break;

        }

    }

    if (success) {

        resultDiv.innerHTML = `
        <h3>✅ Deploy exitoso</h3>

        <p>
        Has ejecutado correctamente el pipeline DevOps.
        </p>
        `;

        resultDiv.className = "success";        

        const username = usernameInput.value.trim();

        const response = await fetch("/api/win", {

            method: "POST",

            headers: {

                "Content-Type": "application/json"

            },

            body: JSON.stringify({

                user: username

            })

        });

        const result = await response.json();

        if (!result.success) {

            alert("No fue posible registrar la victoria.");

            return;

        }    

        await loadHallOfFame();
        deployBtn.disabled = true;
        document
        .querySelectorAll(".step-card")
        .forEach(card => {

            card.style.pointerEvents = "none";

        });
    }

    else {

        resultDiv.className = "error";

        let html =
            "<h3>❌ Pipeline falló</h3>";

        html +=
            "<p>El orden correcto era:</p>";

        html += "<ol>";

        correctOrder.forEach(step => {

            html += "<li>" + step + "</li>";

        });

        html += "</ol>";

        resultDiv.innerHTML = html;

        selectedOrder = [];

        deployBtn.disabled = true;

        renderSteps();

        renderSelection();

        document
            .querySelectorAll(".step-card")
            .forEach(card => {

                card.classList.remove("locked");

                card.style.pointerEvents = "auto";

            });

    }

}

async function loadHallOfFame() {

    try {

        const response = await fetch("/api/ranking");

        if (!response.ok) {

            throw new Error("HTTP " + response.status);

        }

        const players = await response.json();

        console.log(players);

        renderHallOfFame(players);

    }
    catch (error) {

        console.error(error);

        hallOfFameDiv.innerHTML =
            "<p>Error cargando el Hall of Fame.</p>";

    }

}

function renderHallOfFame(players) {

    hallOfFameDiv.innerHTML = "";

    if (players.length === 0) {

        hallOfFameDiv.innerHTML =
            "<p>No hay participantes aún.</p>";

        return;

    }

    players.forEach(player => {

        hallOfFameDiv.innerHTML += `
            <p>
                🏆 <strong>${player.user}</strong>
                - ${player.wins} deploy(s)
            </p>
        `;

    });

}