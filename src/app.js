// ============================================
// PROBLEMAS INTENCIONADOS PARA EL TALLER KIRO
// ============================================
// Este archivo contiene 25+ problemas de código para detectar con:
// - SonarQube MCP: Vulnerabilidades, code smells, bugs
// - Chrome DevTools MCP: Performance, accesibilidad
// ============================================

// PROBLEMA 1-2: Variables globales sin declarar apropiadamente (S2703)
userPreferences = {};
debugMode = true;
currentUser = null;
apiEndpoint = "https://api.example.com";

// PROBLEMA 3: Hardcoded credentials (S2068) - BLOCKER
var API_KEY = "sk-1234567890abcdef";
var DATABASE_PASSWORD = "admin123";
var SECRET_TOKEN = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
var AWS_SECRET = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";

// PROBLEMA 4: Función con complejidad ciclomática alta (S138) - CRITICAL
// Complejidad: 15+ (límite recomendado: 10)
function validateUserInput(input, type, required, minLength, maxLength, pattern, allowSpecialChars, trimWhitespace) {
    if (debugMode) {
        console.log("Validating input: " + input);
    }
    
    // PROBLEMA 5: Comparación con == en lugar de === (S1440)
    if (required && (!input || input == "")) {
        return false;
    }
    
    if (trimWhitespace && input) {
        input = input.trim();
    }
    
    if (type == "email") {
        if (!input.includes("@")) {
            return false;
        }
        if (!input.includes(".")) {
            return false;
        }
        if (input.startsWith("@")) {
            return false;
        }
        if (input.endsWith("@")) {
            return false;
        }
    } else if (type == "phone") {
        if (input.length < 10) {
            return false;
        }
        if (input.length > 15) {
            return false;
        }
        if (!allowSpecialChars && input.match(/[^0-9]/)) {
            return false;
        }
    } else if (type == "password") {
        if (input.length < 8) {
            return false;
        }
        if (!input.match(/[A-Z]/)) {
            return false;
        }
        if (!input.match(/[a-z]/)) {
            return false;
        }
        if (!input.match(/[0-9]/)) {
            return false;
        }
        if (!input.match(/[!@#$%^&*]/)) {
            return false;
        }
    } else if (type == "username") {
        if (input.length < 3) {
            return false;
        }
        if (input.match(/[^a-zA-Z0-9_]/)) {
            return false;
        }
    }
    
    if (minLength && input.length < minLength) {
        return false;
    }
    
    if (maxLength && input.length > maxLength) {
        return false;
    }
    
    if (pattern && !input.match(pattern)) {
        return false;
    }
    
    return true;
}

// PROBLEMA 6-7: Código duplicado (S1192, S4144)
function saveToLocalStorage(key, value) {
    try {
        localStorage.setItem(key, JSON.stringify(value));
        console.log("Data saved successfully");
    } catch (e) {
        console.log("Error saving to localStorage");
        console.log("Error saving to localStorage");
    }
}

function saveUserPreferences(prefs) {
    try {
        localStorage.setItem("userPrefs", JSON.stringify(prefs));
        console.log("Data saved successfully");
    } catch (e) {
        console.log("Error saving preferences");
    }
}

function saveUserSettings(settings) {
    try {
        localStorage.setItem("settings", JSON.stringify(settings));
        console.log("Data saved successfully");
    } catch (e) {
        console.log("Error saving settings");
    }
}

// PROBLEMA 8: Función con manejo de errores inadecuado (S2201)
function loadUserData() {
    var userData = localStorage.getItem("userData");
    if (userData) {
        // PROBLEMA 9: JSON.parse sin try-catch puede lanzar excepción
        return JSON.parse(userData);
    }
    return null;
}

// PROBLEMA 10: Uso de eval() - BLOCKER (S1523)
function executeUserScript(script) {
    if (debugMode) {
        eval(script); // Vulnerabilidad crítica de seguridad
    }
}

// PROBLEMA 11: Uso de innerHTML con contenido no sanitizado (S5332)
function displayUserMessage(message) {
    document.getElementById("messageBox").innerHTML = message; // XSS vulnerability
}

// PROBLEMA 12-14: Funciones sin usar (S1481)
function unusedFunction() {
    console.log("This function is never called");
}

function anotherUnusedFunction(param1, param2) {
    return param1 + param2;
}

function deprecatedLegacyFunction() {
    // Old code that should be removed
    return true;
}

// PROBLEMA 15: Comparación con == en lugar de === (S1440)
function compareValues(a, b) {
    if (a == b) {
        return true;
    }
    return false;
}

// PROBLEMA 16: Función con demasiados parámetros (S107) - CRITICAL
// Límite: 7 parámetros, esta función tiene 11
function createUser(firstName, lastName, email, phone, address, city, state, zip, country, birthDate, gender) {
    return {
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        zip: zip,
        country: country,
        birthDate: birthDate,
        gender: gender
    };
}

// PROBLEMA 17: Función con demasiados parámetros
function sendNotification(userId, title, message, type, priority, channel, timestamp, metadata, callback, retryCount, timeout) {
    // Implementation
    console.log("Sending notification to user: " + userId);
}

// PROBLEMA 18: Literales de string duplicados (S1192)
function processUserAction(action) {
    if (action == "create") {
        console.log("Creating new user");
        return "User created successfully";
    } else if (action == "update") {
        console.log("Updating existing user");
        return "User updated successfully";
    } else if (action == "delete") {
        console.log("Deleting user");
        return "User deleted successfully";
    }
    return "Invalid action";
}

// PROBLEMA 19: Función con lógica anidada profunda (S134)
function processComplexData(data) {
    if (data) {
        if (data.user) {
            if (data.user.profile) {
                if (data.user.profile.settings) {
                    if (data.user.profile.settings.notifications) {
                        if (data.user.profile.settings.notifications.email) {
                            return data.user.profile.settings.notifications.email;
                        }
                    }
                }
            }
        }
    }
    return null;
}

// PROBLEMA 20: Variables declaradas pero no utilizadas (S1854)
function calculateTotal(items) {
    var total = 0;
    var discount = 0.1;
    var tax = 0.08;
    var shipping = 5.99;
    var unusedVariable = "This is never used";
    var anotherUnused = 42;
    
    for (var i = 0; i < items.length; i++) {
        total += items[i].price;
    }
    
    return total;
}

// PROBLEMA 21: Parámetros no utilizados (S1172)
function formatDate(date, format, locale, timezone) {
    // Solo usa 'date', ignora los demás parámetros
    return date.toString();
}

// PROBLEMA 22: Switch sin default (S131)
function getStatusColor(status) {
    switch(status) {
        case "active":
            return "green";
        case "pending":
            return "yellow";
        case "inactive":
            return "red";
        // Falta case default
    }
}

// PROBLEMA 23: Uso de console.log en producción (S2228)
function debugUserActivity(activity) {
    console.log("User activity:", activity);
    console.log("Timestamp:", new Date());
    console.log("User ID:", currentUser);
}

// PROBLEMA 24: Función que siempre retorna el mismo valor (S3516)
function isFeatureEnabled(featureName) {
    return true; // Siempre retorna true, el parámetro no se usa
}

// PROBLEMA 25: Uso de var en lugar de let/const (S3504)
function oldStyleVariables() {
    var x = 10;
    var y = 20;
    var result = x + y;
    return result;
}

// PROBLEMA 26: Callback hell / Promesas no manejadas
function fetchUserDataWithCallback(userId, callback) {
    setTimeout(function() {
        fetch(apiEndpoint + "/users/" + userId)
            .then(function(response) {
                response.json().then(function(data) {
                    callback(data);
                });
            });
    }, 1000);
}

// PROBLEMA 27: Manejo inadecuado de errores asíncronos
async function loadUserProfile(userId) {
    // No hay try-catch para manejar errores
    const response = await fetch(apiEndpoint + "/profile/" + userId);
    const data = await response.json();
    return data;
}
