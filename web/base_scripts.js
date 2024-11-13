






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

        const imageFile = document.getElementById('imagen').files[0]; // Obtén el archivo de imagen del input

        // Verifica si hay un archivo de imagen seleccionado y no está vacío
        if (imageFile && imageFile.size > 0) {
            // Paso 1: Solicita la URL presignada desde la Lambda
            fetch(API_ENDPOINT + "/subirImagen", {
                method: 'GET',
                headers: {
                    'Authorization': token
                }
            })
            .then(response => response.json())
            .then(data => {
                const presignedUrl = data.presigned_url;
                const imageUrl = presignedUrl.split('?')[0]; // Extrae la URL base sin los parámetros de firma
                
                // Paso 2: Sube la imagen usando la URL presignada
                return fetch(presignedUrl, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': imageFile.type  // Define el tipo de contenido basado en el archivo
                    },
                    body: imageFile
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Error al subir la imagen");
                    }
                    return imageUrl;  // Devuelve la URL de la imagen
                });
            })
            .then(imageUrl => {
                // Paso 3: Añade el link de la imagen al inputData
                var inputData = {
                    "urgencia": $('#urgencia').val(),
                    "tipo": $('#tipo').val(),
                    "nombre_propietario": $('#nombre_propietario').val(),
                    "titulo": $('#titulo').val(),
                    "detalle": $('#detalle').val(),
                    "imagen_url": imageUrl  // Guarda la URL de la imagen
                };

                // Paso 4: Envía los datos de la queja con la URL de la imagen
                return $.ajax({
                    url: API_ENDPOINT + "/quejasVecinos",
                    type: 'POST',
                    data: JSON.stringify(inputData),
                    contentType: 'application/json; charset=utf-8',
                    headers: {
                        'Authorization': token
                    }
                });
            })
            .then(() => {
                document.getElementById("complaintSaved").innerHTML = "Funcionó";
            })
            .catch(error => {
                console.error('Error al subir la imagen o guardar la queja:', error);
                alert("No funcionó");
            });
        } else {
            console.log("No se seleccionó ninguna imagen o el archivo está vacío");
            alert("Por favor, selecciona una imagen válida para subir.");
        }
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });
};

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
                        <td><a href='" + data['imagen'] + "' target='_blank'>Ver imagen</a></td> \
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

//Autorizaciones
document.getElementById("getAutorizaciones").onclick = function() {
    console.log("Esta pensando");
    getToken()
    .then(token => {
        if (!token) {
            console.error('No token available');
            return;
        }

        $.ajax({
            url: API_ENDPOINT + "/entradasVisitas",
            type: 'GET',
            contentType: 'application/json; charset=utf-8',
            headers: {
                'Authorization': token  // Utiliza el token almacenado
            },
            success: function (response) {
                console.log(response);
                $('#autorizacionTable tr').slice(1).remove();
                jQuery.each(response, function(i, data) {
                    $("#autorizacionTable").append("<tr> \
                        <td>" + data['nombreVisitante'] + "</td> \
                        <td>" + data['documentoVisitante'] + "</td> \
                        <td>" + data['fechaIngreso'] + "</td> \
                        <td id='estado_" + data['id'] + "'>" + data['estado'] + "</td> \
                        <td><button onclick='cambiarEstado(\"" + data['pk'] + "\", \"" + data['sk']+ "\", \"" + data['id'] + "\", \"Aprobado\")'>Aprobar</button> \
                            <button onclick='cambiarEstado(\"" + data['pk'] + "\", \"" + data['sk']+ "\", \"" + data['id'] + "\", \"Denegado\")'>Denegar</button></td> \
                    </tr>");
                });
            },
            error: function () {
                alert("Error al obtener las solicitudes de ingreso.");
            }
        });
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });      
}

// *** NUEVO *** AJAX POST para cambiar el estado de la solicitud
function cambiarEstado(pk, sk, id, nuevoEstado) {
    getToken()
    .then(token => {
        if (!token) {
            console.error('No token available');
            return;
        }
        var updateData = {
            "pk": pk,
            "sk": sk,
            "nuevo_estado": nuevoEstado
        };

        console.log(updateData)

        $.ajax({
            url: API_ENDPOINT + "/entradasVisitas",
            type: 'PATCH',
            data: JSON.stringify(updateData),
            contentType: 'application/json; charset=utf-8',
            headers: {
                'Authorization': token  // Incluye el token de autorización
            },
            success: function (response) {
                // Actualizar el estado en la tabla
                console.log(id);
                document.getElementById("estado_" + id).innerHTML = nuevoEstado;
            },
            error: function () {
                alert("Error al actualizar el estado de la solicitud.");
            }
        });
    })
    .catch(error => {
        console.error('Error obteniendo el token:', error);
    });
}

function iralformulario() {
    const url = "http://"+ bucket_formulario; // Cambia a la URL que deseas abrir
    window.open(url, "_blank"); // "_blank" abre el enlace en una nueva pestaña o ventana
}