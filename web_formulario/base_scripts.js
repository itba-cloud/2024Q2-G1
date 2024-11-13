


document.getElementById("visitorForm").onsubmit = function(event) {
    event.preventDefault();

    // Obtener los datos del formulario
    const nombreVisitante = document.getElementById("nombreVisitante").value;
    const documentoVisitante = document.getElementById("documentoVisitante").value;
    const fechaIngreso = document.getElementById("fechaIngreso").value;
    const horaIngreso = document.getElementById("horaIngreso").value;
    const emailPropietario = document.getElementById("emailPropietario").value;

    // Preparar los datos para enviar al servidor
    const requestData = {
        nombreVisitante: nombreVisitante,
        documentoVisitante: documentoVisitante,
        fechaIngreso: fechaIngreso,
        horaIngreso: horaIngreso,
        mailPropietario: emailPropietario
    };

    // Llamada AJAX para enviar los datos al servidor
    fetch(API_ENDPOINT+ "/entradasVisitas", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(requestData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.id) {
            document.getElementById("autorizacionMensaje").textContent = "Autorización enviada con éxito.";
            document.getElementById("visitorForm").reset();
        } else {
            console.log(data);
            document.getElementById("autorizacionMensaje").textContent = "Hubo un error al enviar la solicitud.";
        }
    })
    .catch(error => {
        console.error("Error:", error);
        document.getElementById("autorizacionMensaje").textContent = "Error de conexión. Intente nuevamente.";
    });
};

