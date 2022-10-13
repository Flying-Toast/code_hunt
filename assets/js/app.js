function scrambleEffect(element, finalText) {
	const alphabet = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ,.1234567890";

	let currentText = "";

	for (let i = 0; i < finalText.length; i++) {
		let randInd = Math.floor(Math.random() * 26);
		currentText = currentText + alphabet[randInd];
	}

	element.textContent = currentText;

	let i = 0;
	let timer = setInterval(() => {
		if (currentText === finalText) {
			clearInterval(timer);
		}

		if (Math.random() <= 0.9 && currentText[i] !== finalText[i]) {
			let actInd = alphabet.indexOf(finalText[i]);
			let randInd = Math.floor((Math.random() * 7) + actInd - 3);

			randInd = Math.min(randInd, alphabet.length);
			randInd = Math.max(randInd, 0);

			currentText = currentText.substring(0, i) + alphabet[randInd] + currentText.substring(i + 1);
		}

		element.textContent = currentText;

		i = (i + 1) % currentText.length;
	}, 1);
}

addEventListener("load", () => {
	Array.from(document.querySelectorAll(".scramble"))
		.forEach(i => scrambleEffect(i, i.innerText, 4000000));
});
