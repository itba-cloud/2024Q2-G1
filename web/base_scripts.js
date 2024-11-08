






// Variable global para almacenar el token en memoria
let tokenInMemory = null;

// Paso 2: Obtener el código de la URL (en el callback URL)
function getCodeFromUrl() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('code');
}

// Paso 3: Intercambiar el código por un token
async function getToken() {
    if (tokenInMemory) {
        // Si ya tenemos un token en memoria, lo retornamos inmediatamente
        return tokenInMemory;
    }

    const code = getCodeFromUrl();
    if (!code) {
        console.error('No authorization code found in the URL.');
        return null;
    }

    const clientId = userPoolId;
    const redirectUri = REDIRECT_URL;    
    const tokenUrl = COGNITO_DOMAIN;

    const params = new URLSearchParams();
    params.append('grant_type', 'authorization_code');
    params.append('client_id', clientId);
    params.append('code', code);
    params.append('redirect_uri', redirectUri);

    const response = await fetch(tokenUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params
    });

    const data = await response.json();

    if (response.ok) {
        const idToken = data.id_token;
        // Almacenar el token en memoria
        tokenInMemory = idToken;
        return idToken;
    } else {
        console.error('Error getting token:', data);
        return null;
    }
}

// AJAX POST request to save complaint data
document.getElementById("savecomplaint").onclick = function() {
    getToken()
    .then(token => {
        if (!token) {
            console.error('No token available');
            return;
        }
        
        var inputData = {
            "urgencia": $('#urgencia').val(),
            "tipo": $('#tipo').val(),
            "nombre_propietario": $('#nombre_propietario').val(),
            "titulo": $('#titulo').val(),
            "detalle": $('#detalle').val()
        };

        $.ajax({
            url: API_ENDPOINT+ "/quejasVecinos",
            type: 'POST',
            data: JSON.stringify(inputData),
            contentType: 'application/json; charset=utf-8',
            headers: {
                'Authorization': token  // Incluye el token de autorización
            },
            success: function (response) {
                document.getElementById("complaintSaved").innerHTML = "Funcionó";
            },
            error: function () {
                alert("F. No funcionó");
            }
        });
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });
}

// AJAX GET request to retrieve all students
document.getElementById("getstudents").onclick = function(){
    getToken()
    .then(token => {
        if (!token) {
            console.error('No token available');
            return;
        }
        console.log('El token es:', token); // Imprime el token resultante
        $.ajax({
            url: API_ENDPOINT+ "/quejasVecinos",
            type: 'GET',
            contentType: 'application/json; charset=utf-8',
            headers: {
                'Authorization': token  // Utiliza el token almacenado
            },
            success: function (response) {
                $('#quejasVecinos tr').slice(1).remove();
                jQuery.each(response, function(i, data) {          
                    $("#quejasVecinos").append("<tr> \
                        <td>" + data['pk_urg'].substring(4) + "</td> \
                        <td>" + data['fecha'] + "</td> \
                        <td>" + data['nombre_propietario'] + "</td> \
                        <td>" + data['tipo'] + "</td> \
                        <td>" + data['titulo'] + "</td> \
                        <td>" + data['detalle'] + "</td> \
                        <td>" + data['estado'] + "</td> \
                        </tr>");
                });
            },
            error: function () {
                alert("Error retrieving student data.");
            }
        });
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });      
}

// *** NUEVO *** AJAX POST para agregar una reserva
document.getElementById("addReserva").onclick = function() {
    getToken()
    .then(token => {
        if (!token) {
            console.error('No token available');
            return;
        }
        
        var reservaData = {
            "fecha": $('#fecha').val(),
            "espacio": $('#espacio').val(),
            "horario": $('#horario').val()
        };

        $.ajax({
            url: API_ENDPOINT + "/reservasCanchas",
            type: 'POST',
            data: JSON.stringify(reservaData),
            contentType: 'application/json; charset=utf-8',
            headers: {
                'Authorization': token  // Incluye el token de autorización
            },
            success: function (response) {
                document.getElementById("reservaConfirmada").innerHTML = "Reserva realizada correctamente.";
            },
            error: function (xhr) {
                if (xhr.status === 409) {  // Si el error es 409, conflicto
                    var errorResponse = JSON.parse(xhr.responseText);
                    document.getElementById("reservaConfirmada").innerHTML = errorResponse.error;
                } else {
                    alert("Error al realizar la reserva.");
                }
            }
        });
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });
}

// *** NUEVO *** AJAX GET para obtener todas las reservas
document.getElementById("getReservas").onclick = function(){
    getToken()
    .then(token => {
        if (!token) {
            console.error('No token available');
            return;
        }

        $.ajax({
            url: API_ENDPOINT + "/reservasCanchas",
            type: 'GET',
            contentType: 'application/json; charset=utf-8',
            headers: {
                'Authorization': token  // Utiliza el token almacenado
            },
            success: function (response) {
                $('#reservasTable tr').slice(1).remove();
                jQuery.each(response, function(i, data) {          
                    $("#reservasTable").append("<tr> \
                        <td>" + data['Fecha'] + "</td> \
                        <td>" + data['Espacio'] + "</td> \
                        <td>" + data['Horario'] + "</td> \
                        </tr>");
                });
            },
            error: function () {
                alert("Error al obtener las reservas.");
            }
        });
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });      
}

